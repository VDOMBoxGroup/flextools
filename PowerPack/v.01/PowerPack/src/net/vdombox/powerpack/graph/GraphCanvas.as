package net.vdombox.powerpack.graph
{

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.effects.Move;
import mx.events.ChildExistenceChangedEvent;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.graphics.codec.PNGEncoder;
import mx.managers.CursorManager;
import mx.managers.DragManager;
import mx.managers.IFocusManagerComponent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.Base64Encoder;
import mx.utils.NameUtil;
import mx.utils.UIDUtil;

import net.vdombox.powerpack.Template;
import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenu;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenuItem;
import net.vdombox.powerpack.lib.extendedapi.utils.ObjectUtils;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.managers.CashManager;
import net.vdombox.powerpack.managers.ContextManager;
import net.vdombox.powerpack.managers.LanguageManager;
import net.vdombox.powerpack.managers.ProgressManager;
import net.vdombox.powerpack.managers.SelectionManager;

public class GraphCanvas extends Canvas implements IFocusManagerComponent
{
	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//
	//  Variables and properties
	//
	//--------------------------------------------------------------------------

	public static var graphs : Dictionary = new Dictionary();

	private static var defaultItemCaptions : Object = {
		graph_add_state : "Add state",
		graph_add_command : "Add command",
		graph_add_sub : "Add sub",
		graph_cut : "Cut",
		graph_copy : "Copy",
		graph_paste : "Paste",
		graph_clear : "Clear",
		graph_expand_space : "Expand space",
		graph_collapse_space : "Collapse space",
		graph_alert_clear_title : "Confirmation",
		graph_alert_clear_text : "Are you sure want to clear stage?",
		graph_alert_delete_title : "Confirmation",
		graph_alert_delete_text : "Are you sure want to delete seleted states?"
	};

	private static const CLIPBOARD_GRAPH_FORMAT : String = "GRAPH_FORMAT"; 
	
	// Define a static variable.
	private static var _classConstructed : Boolean = classConstruct();

	public static function get classConstructed() : Boolean
	{
		return _classConstructed;
	}

	// Define a static method.
	private static function classConstruct() : Boolean
	{
		if ( !StyleManager.getStyleDeclaration( "GraphCanvas" ) )
		{
			// If there is no CSS definition for GraphCanvas,
			// then create one and set the default value.
			var newStyleDeclaration : CSSStyleDeclaration;

			if ( !(newStyleDeclaration = StyleManager.getStyleDeclaration( "Canvas" )) )
			{
				newStyleDeclaration = new CSSStyleDeclaration();
				newStyleDeclaration.setStyle( "themeColor", "haloBlue" );
			}

			// To get focus during clicking on canvas
			newStyleDeclaration.setStyle( "backgroundColor", 0xeeeeee );
			newStyleDeclaration.setStyle( "backgroundAlpha", 1.0 );

			StyleManager.setStyleDeclaration( "GraphCanvas", newStyleDeclaration, true );
		}

		LanguageManager.setSentences( defaultItemCaptions );

		return true;
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *	Constructor
	 */
	public function GraphCanvas()
	{
		super();

		doubleClickEnabled = true;

		addEventListener( MouseEvent.DOUBLE_CLICK, doubleClickHandler );
		addEventListener( MouseEvent.MOUSE_WHEEL, wheelHandler );
		addEventListener( MouseEvent.MIDDLE_CLICK, middleClickHandler );
		addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
		addEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		addEventListener( "cut", onCut );
		addEventListener( "copy", onCopy );
		addEventListener( GraphCanvasEvent.SELECT_ALL, onSelectAll );
		addEventListener( ChildExistenceChangedEvent.CHILD_ADD, childAddHandler );
		addEventListener( ChildExistenceChangedEvent.CHILD_REMOVE, childRemoveHandler );
		addEventListener( MouseEvent.CONTEXT_MENU, contextMenuDisplayingHandler );

		graphs[this] = this;
	}

	//--------------------------------------------------------------------------
	//
	//  Destructor
	//
	//--------------------------------------------------------------------------

	/**
	 *	Destructor
	 */
	public function dispose() : void
	{
		if ( contextMenu )
		{
			contextMenu.removeEventListener( Event.SELECT, contextMenuSelectHandler );
			SuperNativeMenu( contextMenu ).dispose();
		}

		if ( selectionManager )
		{
			selectionManager.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			selectionManager.dispose();
		}

		removeEventListener( MouseEvent.DOUBLE_CLICK, doubleClickHandler );
		removeEventListener( MouseEvent.MOUSE_WHEEL, wheelHandler );
		removeEventListener( MouseEvent.MIDDLE_CLICK, middleClickHandler );
		removeEventListener( DragEvent.DRAG_ENTER, dragEnterHandler );
		removeEventListener( DragEvent.DRAG_DROP, dragDropHandler );
		removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		removeEventListener( "cut", onCut );
		removeEventListener( "copy", onCopy );
		removeEventListener( GraphCanvasEvent.SELECT_ALL, onSelectAll );
		removeEventListener( ChildExistenceChangedEvent.CHILD_ADD, childAddHandler );
		removeEventListener( ChildExistenceChangedEvent.CHILD_REMOVE, childRemoveHandler );
		removeEventListener( MouseEvent.CONTEXT_MENU, contextMenuDisplayingHandler );

		clear();

		if ( parent )
			parent.removeChild( this );

		delete graphs[this];

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.DISPOSED ) );
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	public var selectionManager : SelectionManager;

	public var addingTransition : Boolean;
	public var currentArrow : Connector;
	public var xml : XML;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  category
	//----------------------------------

	private var _category : String;
	private var _categoryChanged : Boolean;

	[Bindable("categoryChanged")]
	[Inspectable(category="General", defaultValue="other")]
	public function set category( value : String ) : void
	{
		if ( _category != value )
		{
			_category = value;
			if ( xml )
				xml.@category = value;

			_categoryChanged = true;

			invalidateProperties();

			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.CATEGORY_CHANGED ) );
			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		}
	}

	public function get category() : String
	{
		if ( xml )
			return Utils.getStringOrDefault( xml.@category, null );

		return _category;
	}

	//----------------------------------
	//  initial
	//----------------------------------

	private var _initial : Boolean;
	private var _initialChanged : Boolean;

	[Bindable("initialChanged")]
	public function set initial( value : Boolean ) : void
	{
		if ( _initial != value )
		{
			_initial = value;
			if ( xml )
				xml.@initial = value;

			_initialChanged = true;

			invalidateProperties();

			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.INITIAL_CHANGED ) );
			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		}
	}

	public function get initial() : Boolean
	{
		if ( xml )
			return Utils.getBooleanOrDefault( xml.@initial, false );

		return _initial;
	}

	//----------------------------------
	//  name
	//----------------------------------

	[Bindable("nameChanged")]
	override public function set name( value : String ) : void
	{
		if ( super.name != value )
		{
			super.name = value;
			label = value;

			if ( xml )
				xml.@name = value;

			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.NAME_CHANGED ) );
			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		}
	}

	override public function get name() : String
	{
		if ( xml )
			return Utils.getStringOrDefault( xml.@name, null );

		return super.name;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Create child objects.
	 */
	override protected function createChildren() : void
	{
		super.createChildren();

		if ( !selectionManager )
		{
			selectionManager = new SelectionManager( this );
			selectionManager.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}

		if ( ContextManager.FLASH_CONTEXT_MENU && !contextMenu )
		{
			contextMenu = new SuperNativeMenu();

			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_state'], 'add_state' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_command'], 'add_command' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_sub'], 'add_sub' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'separator' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_cut'], 'cut', false, null, false, false ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_copy'], 'copy', false, null, false, false ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_paste'], 'paste', false, null, false, false ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'separator' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_clear'], 'clear' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'separator' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_expand_space'], 'expand_space' ) );
			contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_collapse_space'], 'collapse_space' ) );

			contextMenu.addEventListener( Event.SELECT, contextMenuSelectHandler );
		}

		if ( xml )
		{
			fromXML( xml.toXMLString() );
		}
	}

	override protected function commitProperties() : void
	{
		super.commitProperties();
	}

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------	

	public function alertClear() : void
	{
		if ( parent )
		{
			SuperAlert.show(
					LanguageManager.sentences['graph_alert_clear_text'],
					LanguageManager.sentences['graph_alert_clear_title'],
					Alert.YES | Alert.NO, null, alertRemoveHandler, null, Alert.YES );
		}
	}

	public function alertDelete() : void
	{
		if ( parent )
		{
			SuperAlert.show(
					LanguageManager.sentences['graph_alert_delete_text'],
					LanguageManager.sentences['graph_alert_delete_title'],
					Alert.YES | Alert.NO, null, alertDeleteHandler, null, Alert.YES );
		}
	}

	public function clear() : void
	{
		xml = null;

		var children : Array = getChildren();
		for each( var child : DisplayObject in children )
		{
			if ( child is Connector )
			{
				continue;
			}
			else if ( child is Node )
			{
				(child as Node).dispose();
			}
			else
				removeChild( child );
		}

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	public function expandSpace() : void
	{
		var children : Array = getChildren();
		var arr : Array = [];

		for each( var child : DisplayObject in children )
		{
			if ( child is Node )
			{
				var node : Node = child as Node;
				if ( node.y >= contentMouseY )
				{
					node.endEffectsStarted();
					arr.push( node );
				}
			}
		}

		var move : Move = new Move();
		move.duration = 300;
		move.yBy = Node.DEFAULT_HEIGHT * 3;
		move.play( arr );

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	public function collapseSpace() : void
	{
		var children : Array = getChildren();
		var arr : Array = [];

		for each( var child : DisplayObject in children )
		{
			if ( child is Node )
			{
				var node : Node = child as Node;
				if ( node.y >= contentMouseY )
				{
					node.endEffectsStarted();
					arr.push( node );
				}
			}
		}

		var move : Move = new Move();
		move.duration = 300;
		move.yBy = -Node.DEFAULT_HEIGHT * 2;
		move.play( arr );

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	public function clone() : GraphCanvas
	{
		var newCanvas : GraphCanvas = new GraphCanvas();

		newCanvas.xml = xml;
		newCanvas.category = category;
		newCanvas.initial = initial;

		var dict : Dictionary = new Dictionary( true );
		for each ( var obj : Object in getChildren() )
		{
			if ( obj is Node )
			{
				var newNode : Node = Node( obj ).clone();
				dict[obj] = newNode;
				newCanvas.addChild( newNode );
			}
		}

		for each ( obj in getChildren() )
		{
			if ( obj is Connector )
			{
				var newArrow : Connector = Connector( obj ).clone();

				newArrow.fromObject = dict[Connector( obj ).fromObject];
				newArrow.toObject = dict[Connector( obj ).toObject];

				addArrow( newArrow, newCanvas );
			}
		}

		return newCanvas;
	}

	public function createNode( x : Number = NaN, y : Number = NaN, focused : Boolean = true ) : Node
	{
		var newNode : Node = new Node();

		addChild( newNode );

		newNode.move( isNaN( x ) ? contentMouseX : x, isNaN( y ) ? contentMouseY : y );

		if ( focused )
			newNode.setFocus();

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );

		return newNode;
	}

	public function createArrow( fromNode : Node, toNode : Node, label : String = null ) : Connector
	{
		var newArrow : Connector = new Connector();

		newArrow.fromObject = fromNode;
		newArrow.toObject = toNode;

		newArrow.label = label;
		if ( newArrow.fromObject )
			newArrow.data = Node( newArrow.fromObject ).arrTrans;

		addArrow( newArrow );

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );

		return newArrow;
	}

	private function addArrow( arrow : Connector, canvas : GraphCanvas = null ) : void
	{
		if ( arrow.fromObject && arrow.toObject )
		{
			arrow.interactive = true;

			if ( canvas )
				canvas.addChildAt( arrow, 0 );
			else
				addChildAt( arrow, 0 );
		}
	}

	// gen XML that represents graph structure
	public function toXML() : XML
	{
		if ( xml )
			return xml;

		var graphXML : XML = new XML( <graph/> );
		var children : Array = getChildren();

		graphXML.@name = name;
		graphXML.@initial = initial.toString().toLowerCase();
		graphXML.@category = category;

		graphXML.appendChild( <states/> );
		graphXML.appendChild( <transitions/> );

		for each( var child : DisplayObject in children )
		{
			if ( child is Connector )
			{
				var arrow : Connector = child as Connector;
				var arrowXML : XML = new XML( <transition/> );
				arrowXML.@name = arrow.name;
				arrowXML.@highlighted = arrow.highlighted;
				arrowXML.@enabled = arrow.enabled;
				arrowXML.@source = arrow.fromObject.name;
				arrowXML.@destination = arrow.toObject.name;
				if ( arrow.label )
					arrowXML.label = arrow.label;

				graphXML.transitions.appendChild( arrowXML );
			}
			else if ( child is Node )
			{
				var node : Node = child as Node;
				var nodeXML : XML = new XML( <state/> );
				nodeXML.@name = node.name;
				nodeXML.@type = node.type;
				nodeXML.@category = node.category;
				nodeXML.@enabled = node.enabled;
				nodeXML.@breakpoint = node.breakpoint;
				nodeXML.@x = node.x;
				nodeXML.@y = node.y;
				nodeXML.text = node.text;

				graphXML.states.appendChild( nodeXML );
			}
		}
		return graphXML;
	}

	// gen graph from XML
	public function fromXML( strXML : String ) : Boolean
	{
		var graphXML : XML = new XML( strXML );

		clear();

		name = Utils.getStringOrDefault( graphXML.@name, '' );
		initial = Utils.getBooleanOrDefault( graphXML.@initial );
		category = Utils.getStringOrDefault( graphXML.@category, 'other' );

		for each ( var nodeXML : XML in graphXML.states.elements( "state" ) )
		{
			var newNode : Node = new Node( nodeXML.@category, nodeXML.@type, nodeXML.text );
			newNode.name = Utils.getStringOrDefault( nodeXML.@name, NameUtil.createUniqueName( newNode ) );
			newNode.enabled = Utils.getBooleanOrDefault( nodeXML.@enabled );
			newNode.breakpoint = Utils.getBooleanOrDefault( nodeXML.@breakpoint );
			newNode.x = Number( nodeXML.@x );
			newNode.y = Number( nodeXML.@y );

			addChild( newNode );
		}

		for each ( var arrowXML : XML in graphXML.transitions.elements( "transition" ) )
		{
			var newArrow : Connector = createArrow(
					getChildByName( arrowXML.@source ) as Node,
					getChildByName( arrowXML.@destination ) as Node,
					Utils.getStringOrDefault( arrowXML.label ) );

			newArrow.enabled = Utils.getBooleanOrDefault( arrowXML.@enabled );
			newArrow.highlighted = Utils.getBooleanOrDefault( arrowXML.@highlighted );
		}

		xml = null;

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		return true;
	}

	public function doCopy() : void
	{
		var selectionNum : int = ObjectUtils.dictLength( selectionManager.selection );
		if ( selectionManager && selectionNum > 0 )
		{
			var dataXML : XML = new XML( <copy/> );
			var outArrows : Dictionary = new Dictionary( true );
			var inArrows : Dictionary = new Dictionary( true );

			for ( var obj : Object in selectionManager.selection )
			{
				if ( obj is Node )
				{
					dataXML.appendChild( Node( obj ).toXML() );

					for each( var _out : Connector in Node( obj ).outArrows )
						outArrows[_out] = true;

					for each( var _in : Connector in Node( obj ).inArrows )
						inArrows[_in] = true;
				}
			}

			for each( var arrow : Object in getChildren() )
			{
				if ( arrow is Connector && outArrows[arrow] && inArrows[arrow] )
				{
					dataXML.appendChild( Connector( arrow ).toXML() );
				}
			}

			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData( CLIPBOARD_GRAPH_FORMAT, dataXML );
		}
	}

	public function doPaste() : void
	{
		if ( Clipboard.generalClipboard.hasFormat( CLIPBOARD_GRAPH_FORMAT ) )
		{
			selectionManager.deselectAll();

			var dataXML : XML = XML( Clipboard.generalClipboard.getData( CLIPBOARD_GRAPH_FORMAT ) );
			var namesMap : Object = new Object();

			for each( var xmlNode : XML in dataXML.state )
			{
				var newNode : Node = Node.fromXML( xmlNode );
				namesMap[newNode.name] = NameUtil.createUniqueName( newNode );
				newNode.name = namesMap[newNode.name];
				newNode.selected = true;
				addChild( newNode );
			}

			for each( var xmlArrow : XML in dataXML.transition )
			{
				var newArrow : Connector = createArrow(
						getChildByName( namesMap[xmlArrow.@source] ) as Node,
						getChildByName( namesMap[xmlArrow.@destination] ) as Node,
						Utils.getStringOrDefault( xmlArrow.label ) );

				newArrow.enabled = Utils.getBooleanOrDefault( xmlArrow.@enabled );
				newArrow.highlighted = Utils.getBooleanOrDefault( xmlArrow.@highlighted );
			}

			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		}
		else if ( Clipboard.generalClipboard.hasFormat( ClipboardFormats.TEXT_FORMAT ) )
		{
			newNode = createNode();
			newNode.text = String( Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) );

			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		}
		else if ( Clipboard.generalClipboard.hasFormat( ClipboardFormats.BITMAP_FORMAT ) )
		{
			CursorManager.setBusyCursor();

			ProgressManager.show( ProgressManager.DIALOG_MODE, false );
			callLater( _doGetBitmapClipBoard );

			function _doGetBitmapClipBoard() : void
			{
				var template : Template = ContextManager.templates[0];
				var bitmapData : BitmapData = BitmapData( Clipboard.generalClipboard.getData( ClipboardFormats.BITMAP_FORMAT ) );

				var pngEncoder : PNGEncoder = new PNGEncoder();
				var pngData : ByteArray = pngEncoder.encode( bitmapData );
				pngData.position = 0;

				var encoder : Base64Encoder = new Base64Encoder();
				encoder.encodeBytes( pngData );
				var b64Data : String = encoder.flush();

				var data : ByteArray = new ByteArray();
				data.writeUTFBytes( b64Data );
				var ID : String = UIDUtil.createUID();
				CashManager.setObject( template.fullID, XML( "<object category='image' ID='" + ID + "' name='" + ID + ".png' type='png'/>" ), data );

				newNode = createNode();
				newNode.text = ID;
				newNode.category = NodeCategory.RESOURCE;

				CursorManager.removeBusyCursor();
				ProgressManager.complete();

				dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
			}
		}
		else if ( Clipboard.generalClipboard.hasFormat( ClipboardFormats.FILE_LIST_FORMAT ) )
		{
			return;
		}
	}

	public function doSelectAll() : void
	{
		setFocus();

		if ( selectionManager )
			selectionManager.selectAll();
	}

	public function doCut() : void
	{
		doCopy();
		doDelete();
	}

	public function doDelete() : void
	{
		var children : Array = getChildren();
		for each( var child : Object in children )
		{
			if ( child is Connector )
			{
				continue;
			}
			else if ( child.hasOwnProperty( 'selected' ) && child.selected )
			{
				child.dispose();
			}
		}

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	private function onKeyDown( event : KeyboardEvent ) : void
	{
		if ( event.keyCode == Keyboard.DELETE )
		{
			event.stopPropagation();

			if ( selectionManager && ObjectUtils.dictLength( selectionManager.selection ) > 0 )
				alertDelete();
		}
		else if ( event.controlKey || event.commandKey )
		{
			if ( event.keyCode == Keyboard.X )
			{
				event.stopPropagation();
				doCut();
			}
			else if ( event.keyCode == Keyboard.C )
			{
				//event.stopPropagation();
				doCopy();
			}
			else if ( event.keyCode == Keyboard.V )
			{
				event.stopPropagation();
				doPaste();
			}
		}
	}

	private function contextMenuDisplayingHandler( event : Event ) : void
	{
		for each ( var item : NativeMenuItem in contextMenu.items )
		{
			item.label = LanguageManager.sentences['graph_' + item.name];
		}

		if ( selectionManager && ObjectUtils.dictLength( selectionManager.selection ) > 0 )
		{
			contextMenu.getItemByName( "cut" ).enabled = true;
			contextMenu.getItemByName( "copy" ).enabled = true;
		}
		else
		{
			contextMenu.getItemByName( "cut" ).enabled = false;
			contextMenu.getItemByName( "copy" ).enabled = false;
		}

		if ( Clipboard.generalClipboard.hasFormat( CLIPBOARD_GRAPH_FORMAT ) ||
				Clipboard.generalClipboard.hasFormat( ClipboardFormats.TEXT_FORMAT ) ||
				Clipboard.generalClipboard.hasFormat( ClipboardFormats.BITMAP_FORMAT ) ||
				Clipboard.generalClipboard.hasFormat( ClipboardFormats.FILE_LIST_FORMAT ) )
		{
			contextMenu.getItemByName( "paste" ).enabled = true;
		}
		else
		{
			contextMenu.getItemByName( "paste" ).enabled = false;
		}
	}

	private function onCopy( event : Event ) : void
	{
		doCopy();
	}

	private function onCut( event : Event ) : void
	{
		doCut();
	}

	private function onSelectAll( event : Event ) : void
	{
		doSelectAll();
	}

	private function contextMenuSelectHandler( event : Event ) : void
	{
		switch ( event.target.name )
		{
			case "add_state":
				selectionManager.deselectAll();
				createNode();
				break;

			case "add_command":
				selectionManager.deselectAll();
				var comNode : Node = createNode();
				comNode.category = NodeCategory.COMMAND;
				break;

			case "add_sub":
				selectionManager.deselectAll();
				var subNode : Node = createNode();
				subNode.category = NodeCategory.SUBGRAPH;
				break;

			case "cut":
				doCut();
				break;

			case "copy":
				doCopy();
				break;

			case "paste":
				doPaste();
				break;

			case "clear":
				alertClear();
				break;

			case "expand_space":
				expandSpace();
				break;

			case "collapse_space":
				collapseSpace();
				break;

		}
	}

	private function alertRemoveHandler( event : CloseEvent ) : void
	{
		if ( event.detail == Alert.YES )
		{
			clear();
		}
	}

	private function alertDeleteHandler( event : CloseEvent ) : void
	{
		if ( event.detail == Alert.YES )
		{
			doDelete();
		}
	}

	private function wheelHandler( event : MouseEvent ) : void
	{
		if ( event.shiftKey )
		{
			if ( event.delta > 0 )
			{
				scaleX = scaleY += 0.1;
				verticalScrollPosition += 0.1;
				horizontalScrollPosition += 0.1;
			}
			else if ( scaleX > 0.2 )
			{
				scaleX = scaleY -= 0.1;
				verticalScrollPosition -= 0.1;
				horizontalScrollPosition -= 0.1;
			}
		}
	}

	private function doubleClickHandler( event : MouseEvent ) : void
	{
		selectionManager.deselectAll();
		createNode();
	}

	private function middleClickHandler( event : MouseEvent ) : void
	{
		if ( event.shiftKey )
		{
			scaleX = scaleY = 1.0;
			Utils.scrollToContentPoint( this, new Point( contentMouseX, contentMouseY ) );
		}
	}

	private function dragEnterHandler( event : DragEvent ) : void
	{
		if ( event.dragSource.hasFormat( "items" ) &&
				event.dragSource.dataForFormat( "items" ) &&
				(event.dragSource.dataForFormat( "items" ) as Array).length > 0 &&
				(event.dragSource.dataForFormat( "items" ) as Array)[0] is GraphCanvas )
		{
			DragManager.acceptDragDrop( UIComponent( event.target ) );
			DragManager.showFeedback( DragManager.MOVE );
		}
	}

	private function dragDropHandler( event : DragEvent ) : void
	{
		var items : Array =
				event.dragSource.dataForFormat( "items" ) as Array;

		var graph : GraphCanvas = items[0] as GraphCanvas;

		var newNode : Node = new Node( NodeCategory.SUBGRAPH, NodeType.NORMAL, graph.name );
		addChild( newNode );

		newNode.move( event.localX + horizontalScrollPosition,
				event.localY + verticalScrollPosition );

		newNode.setFocus();

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	private function childRemoveHandler( event : ChildExistenceChangedEvent ) : void
	{
		event.relatedObject.removeEventListener( GraphCanvasEvent.GRAPH_CHANGED, graphChangedHadler );
	}

	private function childAddHandler( event : ChildExistenceChangedEvent ) : void
	{
		event.relatedObject.addEventListener( GraphCanvasEvent.GRAPH_CHANGED, graphChangedHadler );
	}

	private function graphChangedHadler( event : GraphCanvasEvent ) : void
	{
		event.stopImmediatePropagation();
		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

}
}