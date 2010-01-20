import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import mx.controls.Alert;
import mx.core.Application;
import mx.effects.Move;
import mx.effects.easing.Exponential;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import net.vdombox.ide.modules.tree.events.AddTreeElementEvent;
import net.vdombox.ide.modules.tree.events.IndexEvent;
import net.vdombox.ide.modules.tree.events.TreeEditorEvent;

[Embed( source="assets/treeEditor/treeEditor.swf", symbol="rMenu" )]
[Bindable]
public var rMenu : Class;

private var blDrawLine : Boolean = false;

private var btLine : DeleteLineButton = new DeleteLineButton();

private var canLine : Canvas = new Canvas();

private var curLine : Object = new Object();

private var dX : Number;

private var dY : Number;

private var dataManager : DataManager = DataManager.getInstance();

private var dublMain : Canvas = new Canvas();

private var expand : Boolean = false;

/*******
 * 			to Do
 *
 * 		* добавлять новый елемент в самый низ
 * 		* у трее елемента сменить по умолчанию картинку
 * 		* у трии елемента картинка в соответстви с его типом.
 * 		??? массив элементов строить из другого места(массив "сортируемегого дерева" строить так же)
 * 		* делетеБТ должен исчезать когда нажимается другой елемент
 * 		* при создании нового елемента блокировать кнопку "ок"
 * 		* выделить новосозданный елемент
 *
 * 		- бордеры убрать
 * 		- 50% всегда, при наведении 100%
 * 		- Хайд темный фон белые буквы
 * 		- тайтл всередину
 * 		- штмл контенер темный фон , белые буквы
 * 		- кнопку делейт подвинуть
 * 		- кнопка старт по центру
 * 		- надписи по центру
 * 		- нею педж стиль сделать как файлМанаджера
 * 		- Сглаживание
 * */

private var fileManager : FileManager = FileManager.getInstance();

private var firStateOfScrollX : Number;

private var firStateOfScrollY : Number;

private var mainWidth : Canvas = new Canvas();

private var masIndex : Array = new Array();

private var masMaxOfIndex : Array = new Array();

private var massDeletedElemens : Array = new Array(); // of String

private var massIconResouceID : Array = new Array();

private var massLines : Array = new Array();
private var massTreeElements : Array = new Array();


private var needToSave : Boolean;

private var pnFrom : Point = new Point();

private var shSingnature : Boolean;

private var startPage : String;

private var startX : Number;

private var startY : Number;

private var topLevelTypes : XMLList;

private var treeElemenUnderMouse : Object;


private var treeElement : TreeElement = new TreeElement();

private var vctTest : Vector2 = new Vector2();

private var xmlApplicationStructure : XML;

public function dataToXML( massTreeElements : Array, massLines : Array ) : XML
{
	var outXML : XML =
		<Structure/>
		;

	for ( var levels : String in massTreeElements )
	{
		var xmlList : XMLList = new XMLList( "<Object/>" );
		xmlList.@ID = levels;
		xmlList.@left = massTreeElements[ levels ].x;
		xmlList.@top = massTreeElements[ levels ].y;
		xmlList.@ResourceID = massTreeElements[ levels ].resourceID;
		xmlList.@state = massTreeElements[ levels ].state;
		outXML.appendChild( xmlList );
	}

	for ( var level : String in massLines )
		for ( var ind1 : String in massLines[ level ] )
			for ( var ind2 : String in massLines[ level ][ ind1 ] )
			{
				// создаем все елементы дерева
				var object : XMLList = new XMLList( "<Object/>" );

				if ( outXML.Object.( @ID == ind1 ).@ID != ind1 )
				{
					object.@ID = ind1;
					object.@left = massTreeElements[ ind1 ].x;
					object.@top = massTreeElements[ ind1 ].y;
					object.@ResourceID = massTreeElements[ ind1 ].resourceID;
					object.@state = massTreeElements[ ind1 ].state;
					outXML.appendChild( object.toXMLString() );
				}

				//		trace("2 XML to server: " + outXML.toString());
				var levelXMLList : XMLList = new XMLList( "<Level/>" );
				if ( outXML.Object.( @ID == ind1 ).Level.( @Index == level ).@Index != level )
				{
					levelXMLList.@Index = level;
					outXML.Object.( @ID == ind1 ).appendChild( levelXMLList );
				}

				var myXMLList : XMLList = new XMLList( "<Object/>" );
				myXMLList.@ID = ind2;
				myXMLList.@Index = masIndex[ level ][ ind1 ][ ind2 ].index;
				outXML.Object.( @ID == ind1 ).Level.( @Index == level ).appendChild( myXMLList );


				if ( outXML.Object.( @ID == ind2 ).@ID != ind2 )
				{
					object.@ID = ind2;
					object.@left = massTreeElements[ ind2 ].x;
					object.@top = massTreeElements[ ind2 ].y;
					object.@ResourceID = massTreeElements[ ind2 ].resourceID;
					object.@state = massTreeElements[ ind2 ].state;
					outXML.appendChild( object.toXMLString() );
				}
			}

//		trace(" _XML to server: \n" + outXML.toString());
	return outXML;
}


public function getLanguagePhrase( name : String, phrase : String ) : String
{
	var phraseRE : RegExp = /#Lang\((\w+)\)/;
	var phraseID : String = phrase.match( phraseRE )[ 1 ]; //001

	return resourceManager.getString( name, phraseID );
}

private function addEventListenerToTreeElement( treEl : TreeElement ) : TreeElement
{
	treEl.addEventListener( TreeEditorEvent.REDRAW_LINES, treeElementLinesReDrawHandler );
	treEl.addEventListener( TreeEditorEvent.START_DRAW_LINE, startDrawLine );
	treEl.addEventListener( TreeEditorEvent.DELETE, deleteTreeElement );
	treEl.addEventListener( TreeEditorEvent.START_REDRAW_LINES, startReDrawLineHandler );
	treEl.addEventListener( TreeEditorEvent.STOP_REDRAW_LINES, stopReDrawLineHandler );
	treEl.addEventListener( TreeEditorEvent.CHANGE_START_PAGE, changeStartPageHandler );
	treEl.addEventListener( TreeEditorEvent.SAVE_TO_SERVER, saveToServerHandler );
	treEl.addEventListener( TreeEditorEvent.NEED_TO_SAVE, needToSaveHandler );

	treEl.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
	treEl.addEventListener( MouseEvent.MOUSE_OUT, treeElementMouseOutHandler );
	treEl.addEventListener( MouseEvent.MOUSE_OVER, treeElementMouseOverHandler );

	return treEl;
}

private function addTreeEditorListeners() : void
{
	Application.application.addEventListener( KeyboardEvent.KEY_DOWN, spaceKeyDownHandler );
	Application.application.addEventListener( KeyboardEvent.KEY_UP, spaceKeyDownHandler );

	addEventListener( MouseEvent.CLICK, mouseClickHandler );
	colmen2.addEventListener( TreeEditorEvent.HIDE_LINES, hideLines );
	colmen2.addEventListener( TreeEditorEvent.SHOW_LINES, showLines );
	colmen2.addEventListener( TreeEditorEvent.SELECTED_LEVEL, chengeSelectedLevelHandler );

	dataManager.addEventListener( DataManagerEvent.GET_APPLICATION_STRUCTURE_COMPLETE, getApplicationStructure );
	dataManager.addEventListener( DataManagerEvent.CREATE_OBJECT_COMPLETE, createObjectHandler );
	dataManager.addEventListener( DataManagerEvent.PAGE_CHANGED, pageCangeHandler );

	_curTree.addEventListener( TreeEditorEvent.CHANGE_START_PAGE, changeStartPageHandler );
	_curTree.addEventListener( TreeEditorEvent.DELETE, deleteTreeElement );
	_curTree.addEventListener( TreeEditorEvent.SAVE_TO_SERVER, saveToServerHandler );

	btLine.addEventListener( MouseEvent.CLICK, lineClikHandler );
}

private function addTreeElementHandler( adTrEvt : AddTreeElementEvent ) : void
{
	var ID : String = adTrEvt.treeElementID
}

private function addTreeElementLauncher() : void
{
	var rbWnd : AddTreeElementWindow = AddTreeElementWindow( PopUpManager.createPopUp( this,
		AddTreeElementWindow,
		true ) );
	rbWnd.addEventListener( AddTreeElementEvent.TREE_ELEMENT_ADDED, addTreeElementHandler );
}

private function adjustmentTree( xml1 : XML ) : void
{
	var massMap : Array = new Array();
	var massTreeObj : Array = new Array();


	for ( var obID : String in massTreeElements )
	{
		massTreeObj[ obID ] = new TreeObj( obID );
		massTreeObj[ obID ].parent = null;
		massTreeObj[ obID ].child = null;
	}

	if ( !xml1.*.length() )
		return;

	for ( var level : String in massLines )
	{
		if ( colmen2.showLevel( level ) )
		{
			for ( var frsTrElem : String in massLines[ level ] )
				for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
				{
					massTreeObj[ frsTrElem ].child = massTreeObj[ sknTrElem ];
					massTreeObj[ sknTrElem ].parent = massTreeObj[ frsTrElem ];

				}
		}
	}

	var depth : int = 0;
	massMap[ depth ] = -1;
	var itIsCorrectTree : Boolean = false;

	for ( var name : String in massTreeObj )
	{
		if ( massTreeObj[ name ].parent == null && massTreeObj[ name ].childs != null )
		{
			setPosition( name );
			itIsCorrectTree = true;
		}
	}


	if ( !itIsCorrectTree )
	{
		for ( name in massTreeObj )
		{
			if ( massTreeObj[ name ].parent != null && massTreeObj[ name ].childs != null )
				setPosition( name );
		}
	}

	// delete last cycle"s
	for ( name in massTreeObj )
	{
		if ( massTreeObj[ name ].parent && massTreeObj[ name ].mapX == massTreeObj[ name ].parent.mapX && massTreeObj[ name ].mapY == massTreeObj[ name ].parent.mapY )
			setPosition( name );
	}

	/*  placement top level conteiner whithout child */
	var lavel : int
	if ( massMap.length == 1 )
	{
		lavel = 0;
	}
	else
	{
		lavel = massMap.length;

	}
	massMap[ lavel ] = 0;

	var countOfTreeEl : int = Math.round( main.width / 220 );

	for ( name in massTreeObj )
		if ( massTreeObj[ name ].parent == null && massTreeObj[ name ].childs == null )
		{
			massTreeObj[ name ].mapX = massMap[ lavel ]++;
			massTreeObj[ name ].mapY = lavel;

			if ( massMap[ lavel ] == countOfTreeEl )
				massMap[ ++lavel ] = 0;
		}

	for ( var str : String in massTreeObj )
	{

		var moves : Move = new Move();

		moves.target = massTreeElements[ str ];
		moves.duration = 1500;
		moves.easingFunction = Exponential.easeInOut;

		moves.xFrom = massTreeElements[ str ].x;
		moves.yFrom = massTreeElements[ str ].y;

		moves.xTo = Number( massTreeObj[ str ].mapX * 230 );
		moves.yTo = Number( massTreeObj[ str ].mapY * 145 + 30 );

		moves.play();
	}

	function setPosition( inName : String ) : Boolean
	{
		//были ли у этого обьекта
		if ( massTreeObj[ inName ].marked == true )
			return false;
		// помечаем что были
		massTreeObj[ inName ].marked = true;

		if ( massMap[ depth ] == null )
		{
			if ( depth == 0 )
				massMap[ depth ] = 0;
			else
				massMap[ depth ] = massMap[ depth - 1 ];
		}
		else
		{
			massMap[ depth ] = distension();
		}

		massTreeObj[ inName ].mapX = massMap[ depth ];
		massTreeObj[ inName ].mapY = depth;
		massTreeObj[ inName ].depth = depth;


		depth++;
		for ( var name : String in massTreeObj[ inName ].childs )
		{
			if ( setPosition( name ) == true )
				massTreeObj[ inName ].correctPosition();
			;
		}
		depth--;

		return true;
	}

	function distension() : int
	{
		var maxX : int = massMap[ depth - 1 ];
		for ( var i : int = depth; i < massMap.length; i++ )
		{
			if ( massMap[ i ] == null )
			{
				return maxX;
			}
			else
			{
				if ( massMap[ i ] >= maxX )
					maxX = massMap[ i ] + 1;
			}
		}
		return maxX;
	}
}

private function alertClickDeleteTreeElement( event : CloseEvent ) : void
{
	if ( event.detail == Alert.YES )
	{
		dataManager.addEventListener( DataManagerEvent.DELETE_OBJECT_COMPLETE, deleteObjectHandler )
		dataManager.deleteObject( _curTree.target.ID );
	}
}

private function alertClickSaveStructure( event : CloseEvent ) : void
{
	if ( event.detail == Alert.YES )
	{
		saveToServer();
	}
	else
	{
		hide();
	}
}

private function applicationInfoChangeHAndler( dmEvt : DataManagerEvent ) : void
{
	dataManager.removeEventListener( DataManagerEvent.SET_APPLICATION_INFO_COMPLETE, applicationInfoChangeHAndler );
	
	setStartPage();
}

private function autoSpacing() : void
{
	hideLenes();
	adjustmentTree( xmlApplicationStructure );
	
	var delayTimer : Timer = new Timer( 1500, 1 );
	delayTimer.addEventListener( TimerEvent.TIMER, timerHandler ); //		removeMassTreeElements();
	delayTimer.start();
	markButton();
}

private function calculatePointTo( mouseX : Number, mouseY : Number, curTree : Object ) : Object
{
	var tX : int = mouseX - curTree.x;
	var tY : int = mouseY - curTree.y;

	var pnTo : Object = new Object();
	// чтоб мышка не кликала по своей линии

	if ( ( tX > 0 ) )
		pnTo.x = mouseX - 4;
	else
		pnTo.x = mouseX + 4;

	if ( ( tY > 0 ) )
		pnTo.y = mouseY - 4;
	else
		pnTo.y = mouseY + 4;

	return pnTo;
}

private function changeStartPageHandler( treEvt : TreeEditorEvent ) : void
{
	if ( massTreeElements[ startPage ] )
		massTreeElements[ startPage ].selected = false;
	
	startPage = treEvt.ID
	
	var data : XML = new XML( '<Information>' + '<Index>' + startPage + '</Index>' + '</Information>' );
	
	dataManager.addEventListener( DataManagerEvent.SET_APPLICATION_INFO_COMPLETE, applicationInfoChangeHAndler );
	dataManager.setApplicationInformation( dataManager.currentApplicationId, data );
}

private function chengeSelectedLevelHandler( trEvt : TreeEditorEvent ) : void
{
	var level : String = trEvt.ID;
	if ( !massLines[ level ] )
		return;
	
	for ( var fromObj : String in massLines[ level ] )
	{
		for ( var toObj : String in massLines[ level ][ fromObj ] )
		{
			main.removeChild( massLines[ level ][ fromObj ][ toObj ] );
			main.addChild( massLines[ level ][ fromObj ][ toObj ] );
			
			main.removeChild( masIndex[ level ][ fromObj ][ toObj ] );
			main.addChild( masIndex[ level ][ fromObj ][ toObj ] );
		}
	}
	
	for ( var ID : String in massTreeElements )
	{
		main.removeChild( massTreeElements[ ID ] );
		main.addChild( massTreeElements[ ID ] );
	}
}

private function createObjectHandler( dmEvt : DataManagerEvent ) : void
{
	trace( "Page created" );

	var xmlObj : XML = new XML( dmEvt.result );
	var ID : String = xmlObj.Object.@ID;

	var trEl : TreeElement = new TreeElement();
	trEl.ID = ID;

	var typeID : String = xmlObj.Object.@Type.toXMLString();
	trEl.typeID = getIcon( typeID );
	trEl.type = getType( typeID )

	var maxY : Number = 0;
	for ( var tID : String in massTreeElements )
		if ( massTreeElements[ tID ].y > maxY )
			maxY = massTreeElements[ tID ].y;

	trEl.y = maxY + 145;



	massTreeElements[ ID ] = addEventListenerToTreeElement( trEl );
	main.addChild( massTreeElements[ ID ] );

	_curTree.target = massTreeElements[ ID ];

	saveToServer();

	dataManager.addEventListener( DataManagerEvent.PAGE_CHANGED, changePagesHandler );
	main.validateNow();
	main.horizontalScrollPosition = 0;
	main.verticalScrollPosition = 1000;
}


private function createTreeArr( xml : XML ) : void
{
	topLevelTypes = dataManager.getTopLevelTypes();
	var xmlTopLevelObjects : XMLList = dataManager.listPages;

	for each ( var page : XML in xmlTopLevelObjects )
	{
		var ID : String = page.@ID.toXMLString();
		var xmlObj : XML = xml.Object.( @ID == ID )[ 0 ];
		var treeElement : TreeElement = new TreeElement();

		treeElement.ID = ID;
		treeElement.title = page.Attributes.Attribute.( @Name == "title" );
		treeElement.description = page.Attributes.Attribute.( @Name == "description" );

		var typeID : String = page.@Type;
		treeElement.type = getType( typeID );
		treeElement.typeID = getIcon( typeID );
		treeElement = addEventListenerToTreeElement( treeElement );

		/*  проверить если они есть */
		if ( xmlObj )
		{
			treeElement.x = xmlObj.@left.toXMLString();
			treeElement.y = xmlObj.@top.toXMLString();
			treeElement.state = xmlObj.@state.toXMLString();
			treeElement.resourceID = xmlObj.@ResourceID.toXMLString();

			if ( treeElement.resourceID != "" )
				fileManager.loadResource( dataManager.currentApplicationId, treeElement.resourceID, treeElement );
		}
		else
		{
			treeElement.x = 0;
			treeElement.y = 0;
		}

		massTreeElements[ ID ] = treeElement;
	}

}

private function creationCompleteHandler() : void
{
	fileManager = FileManager.getInstance();
}

private function dataManagerListenner( dmnEvt : DataManagerEvent ) : void
{
	dataManager.removeEventListener( DataManagerEvent.SET_APPLICATION_STRUCTURE_COMPLETE,
		dataManagerListenner )
}

private function deleteObject( strID : String ) : void
{
	for ( var level : String in massLines )
		for ( var ind1 : String in massLines[ level ] )
			for ( var ind2 : String in massLines[ level ][ ind1 ] )
				if ( strID == ind1 || strID == ind2 )
				{
					var curIndex : int = masIndex[ level ][ ind1 ][ ind2 ].index;

					masMaxOfIndex[ level ][ ind1 ] = masMaxOfIndex[ level ][ ind1 ] - 1;

					for ( var upDate : String in massLines[ level ][ ind1 ] )
					{
						masIndex[ level ][ ind1 ][ upDate ].maxIndex = masMaxOfIndex[ level ][ ind1 ];

						if ( masIndex[ level ][ ind1 ][ upDate ].index > curIndex )
							masIndex[ level ][ ind1 ][ upDate ].index = masIndex[ level ][ ind1 ][ upDate ].index - 1;
					}

					main.removeChild( masIndex[ level ][ ind1 ][ ind2 ] );
					delete masIndex[ level ][ ind1 ][ ind2 ];

					main.removeChild( massLines[ level ][ ind1 ][ ind2 ] );
					delete massLines[ level ][ ind1 ][ ind2 ];
				}

	// удаляем сам обьект
	main.removeChild( massTreeElements[ strID ] );
	delete massTreeElements[ strID ];

	_curTree.target = null;

	saveToServer();
}

private function deleteObjectHandler( dmEvt : DataManagerEvent ) : void
{
	dataManager.removeEventListener( DataManagerEvent.DELETE_OBJECT_COMPLETE, deleteObjectHandler )
	deleteObject( _curTree.target.ID );
	
	_curTree.target = massTreeElements[ randomTreeElement ];
	
	
	setStartPage();
	saveToServer();
}

private function deleteTreeElement( trEvt : TreeEditorEvent ) : void
{
	_curTree.target = massTreeElements[ trEvt.ID ];
	Alert.show( resourceManager.getString( 'Tree', 'do_you_want_to_delete_element' ), resourceManager.getString( 'Tree',
		'delete_element' ),
		3, this, alertClickDeleteTreeElement );
}

/**
 *
 *		рисуем линию от елемента дерева
 *		до курсора мыши
 *
 */
private function drLine( mEvt : MouseEvent ) : void
{
	if ( mouseX > main.width - 100 && ( main.horizontalScrollPosition + main.width - main.measuredWidth ) < 9 )
		main.horizontalScrollPosition = main.horizontalScrollPosition + 10;
	else if ( mouseX < main.x + 100 && main.horizontalScrollPosition > 9 )
		main.horizontalScrollPosition = main.horizontalScrollPosition - 10;
	else if ( mouseY > main.height - 100 && ( main.verticalScrollPosition + main.height - main.measuredHeight ) < 9 )
		main.verticalScrollPosition = main.verticalScrollPosition + 10;
	else if ( mouseY < main.y + 100 && main.verticalScrollPosition > 9 )
		main.verticalScrollPosition = main.verticalScrollPosition - 10;
	
	vctTest.graphics.clear();
	
	if ( treeElemenUnderMouse )
	{
		vctTest.createVector( _curTree.target, treeElemenUnderMouse, colmen2.selectedItem.level,
			.5 );
	}
	else
	{
		var pnTo : Object = calculatePointTo( mouseX + main.horizontalScrollPosition, mouseY + main.verticalScrollPosition,
			_curTree.target );
		
		vctTest.createVector( _curTree.target, pnTo, colmen2.selectedItem.level, .5 );
	}
}

private function drawLine( obj : Object ) : void
{
	var fromObj : String = _curTree.target.ID.toString();
	var toObj : String = obj.ID.toString();
	var level : String = colmen2.selectedItem.level;

	if ( !massLines[ level ] )
	{
		massLines[ level ] = new Array();
		masIndex[ level ] = new Array();
		masMaxOfIndex[ level ] = new Array();
	}

	if ( !massLines[ level ][ _curTree.target.ID.toString() ] )
	{
		massLines[ level ][ _curTree.target.ID.toString() ] = new Array();
		masIndex[ level ][ _curTree.target.ID.toString() ] = new Array();
		masMaxOfIndex[ level ][ _curTree.target.ID.toString() ] = 0;
	}

	// обьект сам на себя
	if ( toObj == fromObj )
		return;


	// вдруг противоположная линия уже есть..

	if ( massLines[ level ] )
		if ( massLines[ level ][ toObj ] )
			if ( massLines[ level ][ toObj ][ fromObj ] )
				return;

	// вдруг эта линия уже есть..
	if ( massLines[ level ][ fromObj ][ toObj ] == null )
	{
		massLines[ level ][ fromObj ][ toObj ] = new TreeVector( massTreeElements[ fromObj ], massTreeElements[ toObj ],
																 level );

		main.addChildAt( massLines[ level ][ fromObj ][ toObj ], 0 );
		massLines[ level ][ fromObj ][ toObj ].addEventListener( MouseEvent.CLICK, markLines );

		var index : Index = new Index();
		index.level = level;
		index.fromObjectID = fromObj;
		index.targetLine = massLines[ level ][ fromObj ][ toObj ];
		index.maxIndex = index.index = masMaxOfIndex[ level ][ fromObj ] = masMaxOfIndex[ level ][ fromObj ] + 1;

		index.addEventListener( IndexEvent.CHANGE, indexChangeHandler );
		index.visible = shSingnature && colmen2.showLevel( level );

		masIndex[ level ][ fromObj ][ toObj ] = index;
		main.addChild( masIndex[ level ][ fromObj ][ toObj ] );

		markButton();
	}

	for ( var upDate : String in massLines[ level ][ fromObj ] )
		masIndex[ level ][ fromObj ][ upDate ].maxIndex = masMaxOfIndex[ level ][ fromObj ];


}

private function drawLines( xml1 : XML ) : void
{
	for each ( var xmlObj : XML in xml1.children() )
	{
		var obID : String = xmlObj.@ID.toXMLString();

		//создаем массив с Направляю`щими между обьектами
		for each ( var xmlLavel : XML in xmlObj.children() )
		{
			var level : String = xmlLavel.@Index.toXMLString();
			// mass of levels where  level  consist of numbers betvin 0-9
			if ( !massLines[ level ] )
			{
				massLines[ level ] = new Array();
				masIndex[ level ] = new Array();
				masMaxOfIndex[ level ] = new Array();
			}
			if ( !massLines[ level ][ obID ] )
			{
				massLines[ level ][ obID ] = new Array();
				masIndex[ level ][ obID ] = new Array();

			}

			masMaxOfIndex[ level ][ obID ] = 0;
			for each ( var xmlLavelObj : XML in xmlLavel.children() )
			{
				masMaxOfIndex[ level ][ obID ]++;
			}

			var counter : int = 0;
			for each ( xmlLavelObj in xmlLavel.children() )
			{
				var toObjID : String = xmlLavelObj.@ID.toXMLString();
				if ( obID != toObjID && massTreeElements[ obID ] && massTreeElements[ toObjID ] ) // избавляемся от зацикливающихся обьектов
				{

					massLines[ level ][ obID ][ toObjID ] = new TreeVector( massTreeElements[ obID ],
																			massTreeElements[ toObjID ],
																			level );
					massLines[ level ][ obID ][ toObjID ].addEventListener( MouseEvent.CLICK, markLines );
					massLines[ level ][ obID ][ toObjID ].visible = colmen2.showLevel( level );
					main.addChildAt( massLines[ level ][ obID ][ toObjID ], 0 );


					var index : Index = new Index();
					index.level = level;
					index.fromObjectID = obID;
					if ( xmlLavelObj.@Index[ 0 ] )
						index.index = xmlLavelObj.@Index.toXMLString();
					else
						index.index = ++counter;


					index.maxIndex = masMaxOfIndex[ level ][ obID ];
					index.targetLine = massLines[ level ][ obID ][ toObjID ];
					index.visible = shSingnature && colmen2.showLevel( level );
					index.addEventListener( IndexEvent.CHANGE, indexChangeHandler );


					masIndex[ level ][ obID ][ toObjID ] = index;
					main.addChild( masIndex[ level ][ obID ][ toObjID ] );
				}
			}
		}
	}
	// tree Elements to top	
	for ( var ID : String in massTreeElements )
	{
		if ( !main.contains( massTreeElements[ ID ] ) )
			main.addChild( massTreeElements[ ID ] );
	}
}

private function expandAll() : void
{
	expand = !expand;
	for ( var tID : String in massTreeElements )
	{
		massTreeElements[ tID ].state = expand.toString();
	}
	
}

private function getApplicationStructure( dtManEvt : DataManagerEvent ) : void
{
	unMarkButton();
	
	xmlApplicationStructure = dtManEvt.result;
	createTreeArr( xmlApplicationStructure );
	drawLines( xmlApplicationStructure );
	
	_curTree.target = massTreeElements[ dataManager.currentPageId ];
	startPage = dataManager.currentApplicationInformation.Index;
	
	
	setStartPage();
}

private function getIcon( ID : String ) : String
{
	if ( massIconResouceID[ ID ] )
		return massIconResouceID[ ID ]

	for each ( var lavel : XML in topLevelTypes )
	{ //2330fe83-8cd6-4ed5-907d-11874e7ebcf4 /#Lang(001)
		if ( lavel.Information.ID == ID )
		{
			var strLabel : String = lavel.Information.Icon;
			return massIconResouceID[ ID ] = strLabel.substr( 5, 36 );
		}
	}
	return "";
}

private function getType( ID : String ) : String
{
	for each ( var lavel : XML in topLevelTypes )
	{ //2330fe83-8cd6-4ed5-907d-11874e7ebcf4 /#Lang(001)
		if ( lavel.Information.ID == ID )
		{
			var strLabel : String = getLanguagePhrase( lavel.Information.Name, lavel.Information.DisplayName );
			return strLabel;
		}
	}
	return "Void";
}

private function hide() : void
{
	removeAllLines();
	removeMassTreeElements();
	
	if ( main.contains( btLine ) )
	{
		main.removeChild( btLine );
		curLine.mark = false;
	}
	
	masIndex = [];
	masMaxOfIndex = [];
	massLines = [];
}

private function hideHendler() : void
{
	removeTreeEditorListeners();
	
	if ( btSave.selected )
	{
		Alert.show( "Do You Want to save changed structure in tree?", "Tree:", 3, this, alertClickSaveStructure );
	}
	else
	{
		hide();
	}
}

private function hideLenes() : void
{
	for ( var level : String in massLines )
	{
		for ( var frsTrElem : String in massLines[ level ] )
		{
			for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
			{
				masIndex[ level ][ frsTrElem ][ sknTrElem ].visible = false;
				massLines[ level ][ frsTrElem ][ sknTrElem ].visible = false;
			}
		}
	}
}

private function hideLines( treEvt : TreeEditorEvent ) : void
{
	var level : String = treEvt.ID;
	for ( var frsTrElem : String in massLines[ level ] )
		for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
		{
			massLines[ level ][ frsTrElem ][ sknTrElem ].visible = false;
			masIndex[ level ][ frsTrElem ][ sknTrElem ].visible = false;
		}
}



private function hideTreeElement( trEvt : Object ) : void
{
	massTreeElements[ _curTree.target.ID ].resize = true;
}

private function indexChangeHandler( inEvt : IndexEvent ) : void
{
	for ( var toID : String in masIndex[ inEvt.level ][ inEvt.fromObjectID ] )
	{
		var index : Index = masIndex[ inEvt.level ][ inEvt.fromObjectID ][ toID ];

		if ( inEvt.newIndex < inEvt.lastIndex )
		{
			if ( index.index >= inEvt.newIndex && index.index <= inEvt.lastIndex )
			{
				index.index = index.index + 1;
			}
		}
		else
		{
			if ( index.index <= inEvt.newIndex && index.index >= inEvt.lastIndex )
			{
				index.index = index.index - 1;
			}
		}
	}

	markButton();
}


private function lineClikHandler( msEvt : MouseEvent ) : void
{
	removeLine();
}

private function markButton() : void
{
	btSave.mark = true;
}


private function markLines( muEvt : MouseEvent ) : void
{
	curLine.mark = false;
	curLine = muEvt.currentTarget;
	curLine.mark = true;
	btLine.x = main.horizontalScrollPosition + mouseX - btLine.width / 2;
	btLine.y = main.verticalScrollPosition + mouseY - btLine.height / 2;
	btLine.visible = true;
	
	if ( !main.contains( btLine ) )
	{
		main.addChild( btLine );
	}
	muEvt.stopImmediatePropagation();
}

private function mouseClickHandler( msEvt : MouseEvent ) : void
{
	if ( main.contains( btLine ) )
	{
		main.removeChild( btLine );
		curLine.mark = false;
	}
}

/**
 *
 *		Кликнули по обьекту,
 *		- выделяем его
 *		- если надо проводим к нему линию связи с
 *		с от другого обьекта
 */

private function mouseDownHandler( evt : MouseEvent ) : void
{
	// проводим линию
	if ( blDrawLine )
	{
		pnFrom.x = evt.currentTarget.x;
		pnFrom.y = evt.currentTarget.y;
		
		drawLine( evt.currentTarget );
	}
	
	_curTree.target = TreeElement( evt.currentTarget );
	
}


private function mouseMoveHandler( msEvt : MouseEvent ) : void
{
	var curID : String = _curTree.target.ID;
	
	if ( !massTreeElements[ curID ] )
		return;
	
	if ( main.mouseX < dX )
		massTreeElements[ curID ].x = 0;
	else
		massTreeElements[ curID ].x = main.mouseX - dX;
	
	if ( ( main.mouseY - dY ) < 10 )
		massTreeElements[ curID ].y = 10;
	else
		massTreeElements[ curID ].y = main.mouseY - dY;
	
	redrawLines( curID );
}



private function mouseUpHandler( msEvt : MouseEvent ) : void
{
	Application.application.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
	Application.application.removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
	main.removeChild( mainWidth );
}

private function moveSpaceHandler( msEvt : MouseEvent ) : void
{
	if ( startX == -1 )
	{
		startX = msEvt.localX;
		startY = msEvt.localY;
	}
	else
	{
		var dx : Number = startX - msEvt.localX;
	}

}

private function needToSaveHandler( trEvt : TreeEditorEvent ) : void
{
	markButton();
}

private function get randomTreeElement() : String
{
	for ( var ID : String in massTreeElements )
	{
		return ID;
	}

	return "";
}

private function redrawLines( strID : String ) : void
{
	if ( main.contains( btLine ) )
	{
		main.removeChild( btLine );
		curLine.mark = false;
	}

	//trace(strID);
	for ( var level : String in massLines )
		for ( var ind1 : String in massLines[ level ] )
			for ( var ind2 : String in massLines[ level ][ ind1 ] )
				if ( strID == ind1 || strID == ind2 )
					massLines[ level ][ ind1 ][ ind2 ].updateVector();
}

private function removeAllLines() : void
{
//	trace("removeAllLines");
	for ( var level : String in massLines )
		for ( var frsTrElem : String in massLines[ level ] )
			for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
			{
				main.removeChild( masIndex[ level ][ frsTrElem ][ sknTrElem ] );
				delete masIndex[ level ][ frsTrElem ][ sknTrElem ];

				main.removeChild( massLines[ level ][ frsTrElem ][ sknTrElem ] );
				delete massLines[ level ][ frsTrElem ][ sknTrElem ];

				main.validateDisplayList();
			}
}

private function removeLine() : void
{
	for ( var level : String in massLines )
		for ( var frsTrElem : String in massLines[ level ] )
			for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
				if ( curLine == massLines[ level ][ frsTrElem ][ sknTrElem ] )
				{
					masMaxOfIndex[ level ][ frsTrElem ] = masMaxOfIndex[ level ][ frsTrElem ] - 1;

					var curIndex : int = masIndex[ level ][ frsTrElem ][ sknTrElem ].index;


					for ( var upDate : String in massLines[ level ][ frsTrElem ] )
					{
						masIndex[ level ][ frsTrElem ][ upDate ].maxIndex = masMaxOfIndex[ level ][ frsTrElem ];

						if ( masIndex[ level ][ frsTrElem ][ upDate ].index > curIndex )
							masIndex[ level ][ frsTrElem ][ upDate ].index = masIndex[ level ][ frsTrElem ][ upDate ].index - 1;
					}

					main.removeChild( massLines[ level ][ frsTrElem ][ sknTrElem ] );
					delete massLines[ level ][ frsTrElem ][ sknTrElem ];

					main.removeChild( masIndex[ level ][ frsTrElem ][ sknTrElem ] );
					delete masIndex[ level ][ frsTrElem ][ sknTrElem ];
				}

	if ( main.contains( btLine ) )
	{
		main.removeChild( btLine );
		curLine.mark = false;
	}

	markButton();
}

private function removeMassTreeElements() : void
{
	for ( var obID : String in massTreeElements )
	{
		main.removeChild( massTreeElements[ obID ] );
		delete massTreeElements[ obID ];
	}
}

private function removeTreeEditorListeners() : void
{
	Application.application.removeEventListener( KeyboardEvent.KEY_DOWN, spaceKeyDownHandler );
	Application.application.removeEventListener( KeyboardEvent.KEY_UP, spaceKeyDownHandler );

	removeEventListener( MouseEvent.CLICK, mouseClickHandler );

	colmen2.removeEventListener( TreeEditorEvent.HIDE_LINES, hideLines );
	colmen2.removeEventListener( TreeEditorEvent.SHOW_LINES, showLines );

	dataManager.removeEventListener( DataManagerEvent.GET_APPLICATION_STRUCTURE_COMPLETE, getApplicationStructure );
	dataManager.removeEventListener( DataManagerEvent.CREATE_OBJECT_COMPLETE, createObjectHandler );

	_curTree.removeEventListener( TreeEditorEvent.CHANGE_START_PAGE, changeStartPageHandler );
	_curTree.removeEventListener( TreeEditorEvent.DELETE, deleteTreeElement );
	_curTree.removeEventListener( TreeEditorEvent.SAVE_TO_SERVER, saveToServerHandler );

	btLine.removeEventListener( MouseEvent.CLICK, lineClikHandler );
}

private function revert() : void
{
	removeAllLines();
	removeMassTreeElements();

	if ( main.contains( btLine ) )
	{
		main.removeChild( btLine );
		curLine.mark = false;
	}

	masIndex = [];
	masMaxOfIndex = [];
	massLines = [];

	dataManager.getApplicationStructure();
}


private function saveToServer() : void
{
	unMarkButton();

	var dataToServer : XML = dataToXML( massTreeElements, massLines );
	xmlApplicationStructure = dataToServer;

	dataManager.addEventListener( DataManagerEvent.SET_APPLICATION_STRUCTURE_COMPLETE, dataManagerListenner )
	dataManager.setApplicationStructure( dataToServer );
	trace( "********  Data saved  ********\n" + dataToServer.toXMLString() );
}

private function saveToServerHandler( trEvt : TreeEditorEvent ) : void
{
	saveToServer();
}

private function setStartPage() : void
{
//	trace("setStartPage");
	if ( !massTreeElements[ startPage ] )
	{
		startPage = randomTreeElement;
		if ( startPage )
			massTreeElements[ startPage ].selected = true;
	}
	else
	{
		massTreeElements[ startPage ].selected = true;
	}
}

private function showHnadler() : void
{
	if ( !main )
		main = new Canvas();
	
	dublMain.setStyle( "backgroundColor", "#ffffff" );
	
	dublMain.buttonMode = true;
	
	hide();
	addTreeEditorListeners();
	
	dataManager.getApplicationStructure();
}

private function showLenes() : void
{
//	trace("showLenes");
	for ( var level : String in massLines )
		for ( var frsTrElem : String in massLines[ level ] )
			for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
			{
				massLines[ level ][ frsTrElem ][ sknTrElem ].updateVector();
				massLines[ level ][ frsTrElem ][ sknTrElem ].visible = colmen2.showLevel( level )
				masIndex[ level ][ frsTrElem ][ sknTrElem ].visible = shSingnature && colmen2.showLevel( level );

				main.validateDisplayList();
			}
}

private function showLines( treEvt : TreeEditorEvent ) : void
{
	var level : String = treEvt.ID;
	for ( var frsTrElem : String in massLines[ level ] )
		for ( var sknTrElem : String in massLines[ level ][ frsTrElem ] )
		{
			massLines[ level ][ frsTrElem ][ sknTrElem ].visible = true;
			masIndex[ level ][ frsTrElem ][ sknTrElem ].visible = true && shSingnature;
		}
}

private function showSignature() : void
{
	shSingnature = !shSingnature;
	for ( var level : String in massLines )
	{
		if ( colmen2.showLevel( level ) == true )
		{
			for ( var ind1 : String in massLines[ level ] )
			{
				for ( var ind2 : String in massLines[ level ][ ind1 ] )
				{
					masIndex[ level ][ ind1 ][ ind2 ].visible = shSingnature;
				}
			}
		}
	}
}


private function spaceKeyDownHandler( kbEvt : KeyboardEvent ) : void
{
	if ( kbEvt.charCode != 32 )
		return;

//	trace(kbEvt.charCode);

	dublMain.width = main.measuredWidth;
	dublMain.height = main.measuredHeight

	if ( kbEvt.type == KeyboardEvent.KEY_DOWN )
	{
		if ( !main.contains( dublMain ) )
		{
			dublMain.alpha = 0.05;
			main.addChild( dublMain );
//			trace("KeysDown");
			Application.application.addEventListener( MouseEvent.MOUSE_DOWN, spaceMouseHandler );
			Application.application.addEventListener( MouseEvent.MOUSE_UP, spaceMouseHandler );
		}
	}
	else
	{
		if ( main.contains( dublMain ) )
		{
			dublMain.alpha = 1;
			main.removeChild( dublMain );
//			trace("KeysUp");
			Application.application.removeEventListener( MouseEvent.MOUSE_DOWN, spaceMouseHandler );
			Application.application.removeEventListener( MouseEvent.MOUSE_UP, spaceMouseHandler );
			Application.application.removeEventListener( MouseEvent.MOUSE_MOVE, spaceMouseHandler );
		}
	}
}

private function spaceMouseHandler( msEvt : MouseEvent ) : void
{
	var pt : Point = new Point( msEvt.localX, msEvt.localY );
	pt = msEvt.target.localToGlobal( pt );
	pt = main.globalToLocal( pt );


	if ( msEvt.type == MouseEvent.MOUSE_DOWN )
	{
		firStateOfScrollX = main.horizontalScrollPosition;
		firStateOfScrollY = main.verticalScrollPosition;

//		trace("==DOWN==");
		startX = pt.x;
		startY = pt.y;

		Application.application.addEventListener( MouseEvent.MOUSE_MOVE, spaceMouseHandler );
	}
	else if ( msEvt.type == MouseEvent.MOUSE_UP )
	{
//		trace("==UP==");
		Application.application.removeEventListener( MouseEvent.MOUSE_MOVE, spaceMouseHandler );
	}
	else if ( msEvt.type == MouseEvent.MOUSE_MOVE )
	{
		var dx : Number = startX - pt.x;
		var dy : Number = startY - pt.y;

		main.horizontalScrollPosition = firStateOfScrollX + dx;
		main.verticalScrollPosition = firStateOfScrollY + dy;
//		trace("==MOVE== : " + dx );
	}
}

/**
 *
 *		запускаем прорисовку линию от елемента дерева
 *		до курсора мыши
 *
 */
private function startDrawLine( trEvt : TreeEditorEvent ) : void
{
	if ( !colmen2.openedEyeOfSelectedLevel )
		return;
	
	vctTest = new Vector2();
	main.addChild( vctTest ); //--для рисования связывающей линии
	addEventListener( MouseEvent.MOUSE_MOVE, drLine );
	
	blDrawLine = true; //говорим что рисуем линию
	addEventListener( MouseEvent.MOUSE_DOWN, stopDrawLine );
	drLine( new MouseEvent( MouseEvent.MOUSE_OVER ) );
	vctTest.graphics.clear();
}

private function startReDrawLineHandler( trEvt : TreeEditorEvent ) : void
{
	// object to Top
	main.removeChild( massTreeElements[ trEvt.ID ] );
	main.addChild( massTreeElements[ trEvt.ID ] );
	
	dX = main.mouseX - massTreeElements[ trEvt.ID ].x;
	dY = main.mouseY - massTreeElements[ trEvt.ID ].y;
	
	main.addChild( mainWidth );
	
	mainWidth.x = main.width - 20;
	mainWidth.y = main.height - 20;
	
	if ( main.horizontalScrollPosition )
		mainWidth.x = mainWidth.x + main.horizontalScrollPosition;
	
	if ( main.verticalScrollPosition )
		mainWidth.y = mainWidth.y + main.verticalScrollPosition;
	
	Application.application.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
	Application.application.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
}


/**
 * ресурсы
 *		перестаем рисовать линию от елемента дерева
 *		до курсора мыши
 *
 */
private function stopDrawLine( msEvt : MouseEvent ) : void
{
	removeEventListener( MouseEvent.MOUSE_MOVE, drLine );
	removeEventListener( MouseEvent.MOUSE_DOWN, stopDrawLine );
	
	vctTest.clear();
	main.removeChild( vctTest ); ///-------------***********
	blDrawLine = false; //говорим что НЕ рисуем линию
}

private function stopReDrawLineHandler( trEvt : TreeEditorEvent ) : void
{
	main.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
	
	var curID : String = _curTree.target.ID;
	redrawLines( curID );
}

private function timerHandler( tmEvt : TimerEvent ) : void
{
	showLenes();
	
	_curTree.target = massTreeElements[ dataManager.currentPageId ];
	
	setStartPage();
	
	if ( needToSave )
		saveToServer();
	
	needToSave = false;
}

private function treeElementLinesReDrawHandler( trEvt : TreeEditorEvent ) : void
{
	if ( trEvt.currentTarget.ID != null )
		redrawLines( trEvt.currentTarget.ID );
}

private function treeElementMouseOutHandler( msEvt : MouseEvent ) : void
{
	treeElemenUnderMouse = null;
	msEvt.currentTarget.availabled = true;
	
}

private function treeElementMouseOverHandler( msEvt : MouseEvent ) : void
{
	if ( blDrawLine )
	{
		msEvt.currentTarget.availabled = false;
	}
	treeElemenUnderMouse = msEvt.currentTarget;
}


private function unMarkButton() : void
{
	btSave.mark = false;
}
