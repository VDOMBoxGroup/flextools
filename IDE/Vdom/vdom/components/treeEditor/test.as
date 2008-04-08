// ActionScript file
		
		import flash.events.MouseEvent;
		
		import vdom.components.treeEditor.TreeElement;
		import vdom.events.DataManagerEvent;
		import vdom.events.TreeEditorEvent;
		
	 [Bindable]
   private var arrAppl: Array = new Array();
     [Bindable]
   public var selectedAppl:Object;  
   
   	[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='rMenu')]
	[Bindable]
	public var rMenu:Class; 

private function removeAllLines():void
{
	for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
				{
					main.removeChild(massLines[level][frsTrElem][sknTrElem]);
					delete massLines[level][frsTrElem][sknTrElem];
				}
}

private function deleteObject(strID:String):void
{
	for (var level:String in massLines)
		for(var ind1:String in massLines[level])
			for(var ind2:String in massLines[level][ind1])
				if (strID == ind1 || strID == ind2)
				{
					 main.removeChild( massLines[level][ind1][ind2]);
					 delete massLines[level][ind1][ind2];
				}
	// удаляем сам обьект
	main.removeChild(massTreeElements[strID]);
	delete massTreeElements[strID];
	
	curTree = null;
	
	saveToServer();
}

private function setDisplayNames():void
{
	arrAppl = [];
	var types:XMLList = dataManager.getTopLevelTypes();
	for each(var lavel:XML in types )
	{																
			var strLabel:String = getLanguagePhrase(lavel.Information.Name, lavel.Information.DisplayName);
			var strID:String = lavel.Information.ID;
			arrAppl.push({label:strLabel, data:strID});
	}
	
	btAddTreeElement.enabled = false;
}
private function treeElementMousUpHandler():void
{
		var dx:Number = 0;
		var dy:Number = 0;
		
		if(curTree.x <0)
			dx -=  curTree.x
		
		if(curTree.y <0)
			dy -=  curTree.y
		
		if(dx || dy)
		{
			for (var ID:String in massTreeElements)
			{
				massTreeElements[ID].x += dx;
				massTreeElements[ID].y += dy; 
			}
			
			for (var level:String in massLines)
				for (var frsTrElem:String in massLines[level])
					for (var sknTrElem:String in massLines[level][frsTrElem])
					massLines[level][frsTrElem][sknTrElem].updateVector();
			
			if(dx)	main.horizontalScrollPosition += dx;
			if(dy)	main.verticalScrollPosition	  += dy;
		}
}


private function drawLine(obj:Object):void
{
	var fromObj:String = curTree.ID.toString();
	var toObj:String = obj.ID.toString();
	var necessaryLevel:String = colmen2.selectedItem.level;

	if(!massLines[necessaryLevel]) 
		massLines[necessaryLevel] = new Array();
	
	if(!massLines[necessaryLevel][curTree.ID.toString()]) 
		massLines[necessaryLevel][curTree.ID.toString()] = new Array();
	
	// обьект сам на себя
	if(toObj == fromObj)return;
	
	// может эта линия уже есть?
	for (var level:String in massLines)
		for (var frsTrElem:String in massLines[level])
			for (var sknTrElem:String in massLines[level][frsTrElem])
				if((frsTrElem == fromObj && sknTrElem == toObj ) ||
					(frsTrElem == toObj && sknTrElem ==  fromObj ))
					{	
						curTree = obj;
						return;
					}
	
	
	massLines[necessaryLevel][fromObj][toObj] 	= 
	new TreeVector(massTreeElements[fromObj], massTreeElements[toObj], necessaryLevel);
	
	main.addChildAt(massLines[necessaryLevel][fromObj][toObj], 0);
	massLines[necessaryLevel][fromObj][toObj].addEventListener(MouseEvent.CLICK, markLines);
}

private function adjustmentTree(xml1:XML):void
{
	var massMap:Array = new Array();
	var massTreeObj:Array = new Array();
	for each(var xmlObj:XML in xml1.children())
	{
		
		var obID:String = xmlObj.@ID.toXMLString();
		 massTreeObj[obID] = new TreeObj(obID);
	}
	
	for each( xmlObj in xml1.children())
	{
		var fromObID:String = xmlObj.@ID.toXMLString(); 
		for each(var xmlLavel:XML in xmlObj.children())
		{
			for each(var xmlLavelObj:XML in xmlLavel.children())
			{
				var toObjID:String = xmlLavelObj.@ID.toXMLString();
				massTreeObj[fromObID].child = massTreeObj[toObjID];
				massTreeObj[toObjID].parent = massTreeObj[fromObID];
			}
		}
	}
	
	var depth:int = 0;
	var itIsCorrectTree:Boolean = false;
	for (var name:String in massTreeObj)
		if (massTreeObj[name].parent == null)
		{
			setPosition(name);	
			itIsCorrectTree = true;
		} 
	if(itIsCorrectTree)
		for (var str:String in massTreeObj)
		{
			massTreeElements[str].x  = massTreeObj[str].mapX * 220;
			massTreeElements[str].y  = massTreeObj[str].mapY * 60 + 40;
		}
		
	function setPosition(inName:String):void
	{
		if (massMap[depth] == null)
		{
			if (depth == 0)massMap[depth] = 0;
				else massMap[depth] = massMap[depth-1];
		}
		else
		{
			massMap[depth] = distension();
		} 
		
		massTreeObj[inName].mapX = massMap[depth];
		massTreeObj[inName].mapY = depth;
		massTreeObj[inName].depth = depth;
	
		
		depth++;
		for (var name:String in massTreeObj[inName].childs)
		{
			
			setPosition(name);
		}
		depth--;
		
		massTreeObj[inName].correctPosition();
	}
	
	function  distension():int
	{
		var maxX:int =  massMap[depth-1];
		for(var i:int = depth; i< massMap.length; i++)
		{
			if (massMap[i] == null)
			{
				return maxX;
			}else
			{
				if 	(massMap[i]>= maxX) maxX = massMap[i]+1  ;
			}
		}
		return maxX;
	}
}

private function addTreeEditorListeners():void
{
	addEventListener(MouseEvent.CLICK, mouseClickHandler);
	
	colmen2.addEventListener(TreeEditorEvent.HIDE_LINES, hideLines);
	colmen2.addEventListener(TreeEditorEvent.SHOW_LINES, showLines);
	
	dataManager.addEventListener(DataManagerEvent.STRUCTURE_LOADED, getApplicationStructure);
	
	btLine.addEventListener(MouseEvent.CLICK, lineClikHandler );
}

private function removeTreeEditorListeners():void
{
	removeEventListener(MouseEvent.CLICK, mouseClickHandler);
	
	colmen2.removeEventListener(TreeEditorEvent.HIDE_LINES, hideLines);
	colmen2.removeEventListener(TreeEditorEvent.SHOW_LINES, showLines);
	
	dataManager.removeEventListener(DataManagerEvent.STRUCTURE_LOADED, getApplicationStructure);
	
	btLine.removeEventListener(MouseEvent.CLICK, lineClikHandler);
}

private  function removeMassTreeElements():void
{
		for (var obID:String in massTreeElements)
		{
			main.removeChild(massTreeElements[obID]);
			delete massTreeElements[obID];
		}
}

private var topLevelTypes:XMLList;
private function createTreeArr(xml:XML):void
{
	topLevelTypes = dataManager.getTopLevelTypes();
	var xmlTopLevelObjects:XMLList = dataManager.listPages;
	for each(var xmlObj:XML in xml.children())
	{
		var ID:String = xmlObj.@ID.toXMLString();
		var page:XML = xmlTopLevelObjects.(@ID == ID )[0];
		var treeElement:TreeElement = new TreeElement();
			
		//massTreeElements[ID] =  new TreeElement();

		treeElement.ID 			= xmlObj.@ID.toXMLString();
		treeElement.x 			= xmlObj.@left.toXMLString();
		treeElement.y 			= xmlObj.@top.toXMLString();	
		treeElement.state 		= xmlObj.@state.toXMLString();	
		treeElement.resourceID 	= xmlObj.@ResourceID.toXMLString();

		if (treeElement.resourceID!='') 
				fileManager.loadResource(dataManager.currentApplicationId, treeElement.resourceID, treeElement);

		treeElement.name =  page.Attributes.Attribute.(@Name == 'title' );
		treeElement.description = page.Attributes.Attribute.(@Name == 'description' );
		
		
		
		var typeID:String = page.@Type;
		treeElement.type  =  getType(typeID);
		treeElement = addEventListenerToTreeElement(treeElement);
		
		massTreeElements[ID] =  treeElement;
		main.addChild(massTreeElements[ID]);

	}
}

private function getType(ID:String):String
{
	for each(var lavel:XML in topLevelTypes )
	{																//2330fe83-8cd6-4ed5-907d-11874e7ebcf4 /#Lang(001)
			if( lavel.Information.ID == ID) {
			var strLabel:String = getLanguagePhrase(lavel.Information.Name, lavel.Information.DisplayName);
			return  strLabel;}
	}
	return  'Void';
}
public function getLanguagePhrase(name:String, phrase:String):String
{
	var phraseRE:RegExp = /#Lang\((\w+)\)/;
	var phraseID:String = phrase.match(phraseRE)[1]; //001
	
	return resourceManager.getString(name, phraseID);
}

private function get needCreatTree():Boolean
	{
		
		// x,y == 0;
		var calc:int = 0;
		for(var strID:String in massTreeElements)
			if (massTreeElements[strID].x == 0 && massTreeElements[strID].y == 0) 
				calc++;
		//trace('test1: '+calc );		
		if(calc > 2) return true;
		
		// only 1 level
		calc = 0;
		for(var level:String in massLines)
			calc++;
		//trace('test2: ' + calc);	
		if(calc > 1)return true;
		
		//trace('test3 False');
		return false;
	}
	
private function createTreeElement(xmlObj:XML):TreeElement
{
			//trace(xmlObj);
	var obID:String = xmlObj.Object.@ID;
	var treeElement:TreeElement =  new TreeElement();
	treeElement.ID = obID;
	treeElement.name =  xmlObj.Object.Attributes.Attribute.(@Name == 'title' );
	
	treeElement.description = '';
	treeElement.x = 0;
	treeElement.y = 0;	
	treeElement.resourceID = xmlObj.Object.@Type.toXMLString();
	var typeID:String = xmlObj.Object.@Type.toXMLString();
	treeElement.type  =  getType(typeID);

	return treeElement;		
}

private function addEventListenerToTreeElement(treEl:TreeElement):TreeElement
{
			treEl.addEventListener(TreeEditorEvent.REDRAW_LINES , treeElementLinesReDrawHandler);
			treEl.addEventListener(TreeEditorEvent.START_DRAW_LINE , startDrawLine);
			treEl.addEventListener(TreeEditorEvent.DELETE , deleteTreeElement);
			treEl.addEventListener(TreeEditorEvent.START_REDRAW_LINES, startReDrawLineHandler);
			treEl.addEventListener(TreeEditorEvent.STOP_REDRAW_LINES, stopReDrawLineHandler);
			treEl.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			return treEl;
}

private function drawLines(xml1:XML):void
{
	for each(var xmlObj:XML in xml1.children())
	{
		var obID:String = xmlObj.@ID.toXMLString();
		
		//создаем массив с Направляю`щими между обьектами
		for each(var xmlLavel:XML in xmlObj.children())
		{
			var level:String = xmlLavel.@Index.toXMLString();
			// mass of levels where  level  consist of numbers betvin 0-9
			if (!massLines[level]) massLines[level] = new Array();
			if (!massLines[level][obID]) massLines[level][obID] = new Array();
			
			for each(var xmlLavelObj:XML in xmlLavel.children())
			{
				var toObjID:String = xmlLavelObj.@ID.toXMLString();
				if (obID != toObjID)// избавляемся от зацикливающихся обьектов
				{
					massLines[level][obID][toObjID] = new TreeVector(massTreeElements[obID], massTreeElements[toObjID], level);
					massLines[level][obID][toObjID].addEventListener(MouseEvent.CLICK, markLines);

					main.addChildAt(massLines[level][obID][toObjID], 0);
				}
			}
		}
	}
}


/***
	* 
	* ---------- перерисовываем необходимые линии -----------------
	*
	*/
	
private function redrawLines(strID:String):void
{
	//trace(strID);
	for (var level:String in massLines)
		for(var ind1:String in massLines[level])
			for(var ind2:String in massLines[level][ind1])
				if (strID == ind1 || strID == ind2)
					massLines[level][ind1][ind2].updateVector();
}

private function  removeLine():void
{
	for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
					if(curLine  == massLines[level][frsTrElem][sknTrElem] )
					{
						main.removeChild(massLines[level][frsTrElem][sknTrElem]);
						delete massLines[level][frsTrElem][sknTrElem];
						btLine.visible = false;
					}
}

private function saveToServer():void
{
	var dataToServer:XML =  dataToXML(massTreeElements, massLines);
	if(dataToServer.*.length() > 0)
	{										
	 	dataManager.addEventListener(DataManagerEvent.STRUCTURE_SAVED, dataManagerListenner)
		dataManager.setApplactionStructure(dataToServer);
	}
}

public function dataToXML(massTreeElements:Array, massLines:Array ):XML
{
	var outXML:XML = <Structure/> ;
	
	for (var levels:String in massTreeElements)
	{
		var xmlList:XMLList = new XMLList('<Object/>');
		xmlList.@ID = levels;
				xmlList.@left = massTreeElements[levels].x;
				xmlList.@top = massTreeElements[levels].y;
				xmlList.@ResourceID = massTreeElements[levels].resourceID;
				xmlList.@state = massTreeElements[levels].state;
				outXML.appendChild(xmlList.toXMLString());
	}

//	trace('1 XML to server: ' + outXML.toString())
	for (var level:String in massLines)
	for(var ind1:String in massLines[level])
		for(var ind2:String in massLines[level][ind1])
		{

			// создаем все елементы дерева
			var object:XMLList = new XMLList('<Object/>');

			if (outXML.Object.(@ID == ind1).@ID != ind1 )
			{
				object.@ID = ind1;
				object.@left = massTreeElements[ind1].x;
				object.@top = massTreeElements[ind1].y;
				object.@ResourceID = massTreeElements[ind1].resourceID;
				object.@state = massTreeElements[ind1].state;
				outXML.appendChild(object.toXMLString());
			}
			
	//		trace('2 XML to server: ' + outXML.toString());
			var levelXMLList:XMLList = new XMLList('<Level/>');
			if(outXML.Object.(@ID == ind1).Level.(@Index == level).@Index != level)
			{
				levelXMLList.@Index = level;
				outXML.Object.(@ID == ind1).appendChild(levelXMLList);
			}
			
			var myXMLList:XMLList = new XMLList('<Object/>') ;
			myXMLList.@ID = ind2;
			outXML.Object.(@ID == ind1).Level.(@Index == level).appendChild(myXMLList);
			
			
			if (outXML.Object.(@ID == ind2).@ID != ind2 )
			{
				object.@ID = ind2;
				object.@left = massTreeElements[ind2].x;
				object.@top = massTreeElements[ind2].y;
				object.@ResourceID = massTreeElements[ind2].resourceID;
				object.@state = massTreeElements[ind2].state;
				outXML.appendChild(object.toXMLString());
			}	
		}
		
	//	trace(' _XML to server: ' + outXML.toString());
		return outXML;
}
		
private function calculatePointTo(mouseX:Number, mouseY:Number, curTree:Object):Object
{
	var tX:int = mouseX - curTree.x;
	var tY:int = mouseY - curTree.y;
	
	var pnTo:Object = new Object();
	// чтоб мышка не кликала по своей линии
	
	if((tX>0))	pnTo.x = mouseX - 10;
		else pnTo.x = mouseX + 10;
	
	if( (tY>0))	pnTo.y = mouseY - 10;
		else pnTo.y = mouseY + 10;
		
	return pnTo;
}