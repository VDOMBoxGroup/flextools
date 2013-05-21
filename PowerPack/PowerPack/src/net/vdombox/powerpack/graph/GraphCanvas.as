package net.vdombox.powerpack.graph
{

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.collections.Sort;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.effects.Move;
import mx.events.ChildExistenceChangedEvent;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.ResourceEvent;
import mx.graphics.codec.PNGEncoder;
import mx.managers.CursorManager;
import mx.managers.DragManager;
import mx.managers.IFocusManagerComponent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.Base64Encoder;
import mx.utils.NameUtil;
import mx.utils.StringUtil;
import mx.utils.UIDUtil;

import net.vdombox.powerpack.control.controlbar.GraphEditorControlBar;

import net.vdombox.powerpack.control.controlbar.GraphEditorControlBar;
import net.vdombox.powerpack.events.ResourcesEvent;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenu;
import net.vdombox.powerpack.lib.extendedapi.ui.SuperNativeMenuItem;
import net.vdombox.powerpack.lib.extendedapi.utils.ObjectUtils;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.lib.player.graph.NodeCategory;
import net.vdombox.powerpack.lib.player.graph.NodeType;
import net.vdombox.powerpack.lib.player.managers.ContextManager;
import net.vdombox.powerpack.lib.player.managers.LanguageManager;
import net.vdombox.powerpack.lib.player.popup.AlertPopup;
import net.vdombox.powerpack.lib.player.template.Template;
import net.vdombox.powerpack.managers.BuilderContextManager;
import net.vdombox.powerpack.managers.CashManager;
import net.vdombox.powerpack.managers.ProgressManager;
import net.vdombox.powerpack.managers.SelectionManager;
import net.vdombox.powerpack.sdkcompiler.SDKCompiler;
import net.vdombox.powerpack.template.BuilderTemplate;
import net.vdombox.powerpack.utils.GeneralUtils;
import net.vdombox.powerpack.managers.ResourcesManager;

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

	[Bindable]
	public var initial : Boolean;
	
	public var creationCompleted : Boolean = false;
	
	public static var graphs : Dictionary = new Dictionary();

	private static var defaultItemCaptions : Object = {
		graph_add_state : "Add state",
		graph_add_command : "Add command",
		graph_add_sub : "Add subgraph",
		graph_add_resource : "Add resource",
		graph_cut : "Cut",
		graph_copy : "Copy",
		graph_paste : "Paste",
		graph_clear : "Clear",
		graph_expand_space : "Expand space",
		graph_collapse_space : "Collapse space",
		graph_alert_clear_title : "Confirmation",
		graph_alert_clear_text : "Are you sure want to clear stage?",
		graph_alert_delete_title : "Confirmation",
		graph_alert_delete_text : "Are you sure you want to remove selected states?"
	};

	public static const CLIPBOARD_GRAPH_FORMAT : String = "GRAPH_FORMAT"; 
	
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
			
		addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
	}
	
	private function creationCompleteHandler (event : FlexEvent) : void
	{
		removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		
		creationCompleted = true;
		
		dispatchEvent ( new GraphCanvasEvent(GraphCanvasEvent.SELECTION_CHANGED) );
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
			selectionManager.removeEventListener( SelectionManager.SELECTION_CHANGED, selManagerSelectionChangedHandler );
				
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
	//  name
	//----------------------------------

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

	[Bindable("nameChanged")]
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
			selectionManager.addEventListener( SelectionManager.SELECTION_CHANGED, selManagerSelectionChangedHandler );
		}

		if ( ContextManager.FLASH_CONTEXT_MENU && !contextMenu )
			addContextMenu();

		if ( xml )
		{
			fromXML();
		}
	}
	
	public function selManagerSelectionChangedHandler (event : Event) : void
	{
		dispatchEvent ( new GraphCanvasEvent(GraphCanvasEvent.SELECTION_CHANGED) );
	}
	
	private function addContextMenu () : void
	{
		contextMenu = new SuperNativeMenu();
		
		contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_state'], 'add_state' ) );
		contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_command'], 'add_command' ) );
		contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_sub'], 'add_sub' ) );
		contextMenu.addItem( new SuperNativeMenuItem( 'normal', LanguageManager.sentences['graph_add_resource'], 'add_resource' ) );
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
			AlertPopup.show(
						LanguageManager.sentences['graph_alert_clear_text'],
						LanguageManager.sentences['graph_alert_clear_title'],
						Alert.YES | Alert.NO, null, alertRemoveHandler, null, Alert.YES );
		}
	}

	public function get selectedNodesAmount () : int
	{
		if (!selectionManager)
			return 0;
		
		var nodesAmount : Number = 0;
		
		for each (var selectedObject : Object in selectionManager.selection)
		{
			if (selectedObject is Node)
				nodesAmount ++;
		}
		
		return nodesAmount;
	}
	
	public function get selectedNodes () : Array
	{
		var selectedNodes : Array = [];
		
		if (!selectionManager)
			return selectedNodes;
		
		for each (var selectedObject : Object in selectionManager.selection)
		{
			if (selectedObject is Node)
				selectedNodes.push(selectedObject as Node);
		}
		
		return selectedNodes;
	}
	
	public function get selectedArrowsAmount () : int
	{
		var selArrowsAmount : int = 0;
		
		for each( var child : Object in getChildren() )
		{
			if ( child is Connector && Connector(child).focused)
				selArrowsAmount ++;
		}
		
		return selArrowsAmount;
	}
	
	public function alertDelete() : void
	{
		if (selectedNodesAmount <= 0)
			return;
		
		if ( parent && selectionManager.selection)
		{
			AlertPopup.show(
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
		var yBy : Number = Node.DEFAULT_HEIGHT * 3;
		
		var topY : Number = contentMouseY >= 0 ? contentMouseY : 0;
		
		var children : Array = getChildren();
		var arr : Array = [];

		for each( var child : DisplayObject in children )
		{
			if ( child is Node )
			{
				var node : Node = child as Node;
				if ( node.y >= topY )
				{
					node.endEffectsStarted();
					arr.push( node );
				}
			}
		}

		var move : Move = new Move();
		move.duration = 300;
		move.yBy = yBy;
		move.play( arr );

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	public function collapseSpace() : void
	{
		var yBy : Number = -Node.DEFAULT_HEIGHT * 2;
		
		var topY : Number = contentMouseY >= 0 ? contentMouseY : 0;
		
		var children : Array = getChildren();
		var arr : Array = [];

		for each( var child : DisplayObject in children )
		{
			if ( child is Node )
			{
				var node : Node = child as Node;
				if ( node.y >= topY && node.y + yBy >= topY)
				{
					node.endEffectsStarted();
					arr.push( node );
				}
			}
		}

		var move : Move = new Move();
		move.duration = 300;
		move.yBy = yBy;
		move.play( arr );

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
	}

	public function clone() : GraphCanvas
	{
		var newCanvas : GraphCanvas = new GraphCanvas();

		newCanvas.xml = xml;
		newCanvas.category = category;

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

	public function createNode( category : String = NodeCategory.NORMAL,
								x : Number = NaN, y : Number = NaN,
								focused : Boolean = true,
								edit : Boolean = true,
								text = "") : Node
	{
		var newNode : Node = new Node(category, NodeType.NORMAL, text);

		addChild( newNode );

		var nodeX : Number = isNaN( x ) ? (contentMouseX > 0 ? contentMouseX : 10) : x;
		var nodeY : Number = isNaN( y ) ? (contentMouseY > 0 ? contentMouseY : 10) : y;
		
		newNode.move( nodeX , nodeY );

		if ( focused )
			newNode.setFocus();
		
		if (getChildren().length == 1)
			newNode.type = NodeType.INITIAL;

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );

		if ( edit )
		{
			newNode.edit();

			newNode.preventValidation = true;

			if (category == NodeCategory.SUBGRAPH)
				newNode.triggerAssistMenu();
		}

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

		newArrow.addEventListener( ConnectorEvent.SELECTION_CHANGED, arrowSelectionChangeHandler )
		
		addArrow( newArrow );

		dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );

		return newArrow;
	}
	
	private function arrowSelectionChangeHandler (event : ConnectorEvent) : void
	{
		dispatchEvent ( new GraphCanvasEvent(GraphCanvasEvent.SELECTION_CHANGED) );
	}
	
	public function get selectedArrow () : Connector
	{
		for each( var child : Object in getChildren() )
		{
			if ( child is Connector )
			{
				if (Connector(child).focused)
					return child as Connector;
			}
		}
		
		return null;
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
				{
					var strXML : String = "<label><![CDATA["+arrow.label+"]\]></label>"
					arrowXML.appendChild(new XML(strXML));
				}

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
	public function fromXML( strXML : String = "" ) : Boolean
	{
		var graphXML : XML;
		
		if (!strXML)
			graphXML = xml;
		else
			graphXML = new XML( strXML );

		clear();

		name = Utils.getStringOrDefault( graphXML.@name, '' );
		
		category = Utils.getStringOrDefault( graphXML.@category, 'other' );

		for each ( var nodeXML : XML in graphXML.states.elements( "state" ) )
		{
			var newNode : Node = new Node( nodeXML.@category, nodeXML.@type, nodeXML.text );
			var xmlNodeName : String = nodeXML.@name;
			if (xmlNodeName && xmlNodeName != "")
				newNode.name = xmlNodeName;
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
		if ( selectionManager && selectionManager.selectedObjectsAmount > 0 )
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
		var clipboard : Clipboard = Clipboard.generalClipboard;
		
		if ( clipboard.hasFormat( CLIPBOARD_GRAPH_FORMAT ) )
		{
			selectionManager.deselectAll();

			var dataXML : XML = XML( clipboard.getData( CLIPBOARD_GRAPH_FORMAT ) );
			var namesMap : Object = new Object();

			for each( var xmlNode : XML in dataXML.state )
			{
				var newNode : Node = Node.fromXML( xmlNode, false );
				namesMap[xmlNode.@name] = newNode.name;
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
		else if ( clipboard.hasFormat( ClipboardFormats.TEXT_FORMAT ) )
		{
			var clipboardText : String = String(clipboard.getData( ClipboardFormats.TEXT_FORMAT ));
			
			if (!clipboardText)
				return;
			
			newNode = createNode();
			newNode.text = clipboardText;
			
			dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
		}
		else if ( clipboard.hasFormat( ClipboardFormats.BITMAP_FORMAT ) )
		{
			CursorManager.setBusyCursor();

			ProgressManager.show( ProgressManager.DIALOG_MODE, false );
			callLater( _doGetBitmapClipBoard );

			function _doGetBitmapClipBoard() : void
			{
				var template : BuilderTemplate = ContextManager.templates[0] as BuilderTemplate;
				var bitmapData : BitmapData = BitmapData( clipboard.getData( ClipboardFormats.BITMAP_FORMAT ) );

				var pngEncoder : PNGEncoder = new PNGEncoder();
				var pngData : ByteArray = pngEncoder.encode( bitmapData );
				pngData.position = 0;

				var encoder : Base64Encoder = new Base64Encoder();
				encoder.insertNewLines = false;
				encoder.encodeBytes( pngData );
				
				var b64Data : String = encoder.flush();
				var data : ByteArray = new ByteArray();
				data.writeUTFBytes( b64Data );
				
				resourcesManager.createResource("", "png", data);

				CursorManager.removeBusyCursor();
				ProgressManager.complete();

				dispatchEvent( new GraphCanvasEvent( GraphCanvasEvent.GRAPH_CHANGED ) );
			}
		}
		else if ( clipboard.hasFormat( ClipboardFormats.FILE_LIST_FORMAT ) )
		{
			return;
		}
	}
	
	private function addResource() : void
	{
		CursorManager.setBusyCursor();

		ProgressManager.complete();
		ProgressManager.show( ProgressManager.DIALOG_MODE, false );

		resourcesManager.addEventListener( ResourcesEvent.COMPLETE, addResourceCompleteHandler);
		resourcesManager.addEventListener( ResourcesEvent.CANCEL, addResourceCompleteHandler);
		resourcesManager.addEventListener( ResourcesEvent.ERROR, addResourceCompleteHandler);

		resourcesManager.addResource();

		function addResourceCompleteHandler( event : ResourcesEvent ) : void
		{
			resourcesManager.removeEventListener( ResourcesEvent.COMPLETE, addResourceCompleteHandler);
			resourcesManager.removeEventListener( ResourcesEvent.CANCEL, addResourceCompleteHandler);
			resourcesManager.removeEventListener( ResourcesEvent.ERROR, addResourceCompleteHandler);

			CursorManager.removeBusyCursor();
			ProgressManager.complete();

			switch (event.type)
			{
				case ResourcesEvent.ERROR :
				{
					AlertPopup.show(event.errorMsg, "Error");
					break;
				}

				case ResourcesEvent.COMPLETE :
				{
					addResourceNode(event.resourceID);

					break;
				}
			}
		}
	}

	private function addResourceNode( resourceID : String ) : void
	{
		var newNode : Node;

		newNode = createNode(NodeCategory.RESOURCE);
		newNode.text = resourceID;
	}

	
	private function get resourcesManager() : ResourcesManager
	{
		return ResourcesManager.getInstance();
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
		else 
		{
			if ( GeneralUtils.isCutCombination(event) )
			{
				event.stopPropagation();
				doCut();
			}
			else if ( GeneralUtils.isCopyCombination(event) )
			{
				//event.stopPropagation();
				doCopy();
			}
			else if ( GeneralUtils.isPasteCombination(event) )
			{
				event.stopPropagation();
				doPaste();
			}
			
		}
	}
	
	private function contextMenuDisplayingHandler( event : Event ) : void
	{
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

	public function controlBarItemClickHandler (itemName : String, destinationObjectType : String) : void
	{
		switch(destinationObjectType)
		{
			case GraphEditorControlBar.DESTINATION_OBJECT_GRAPH_NODE:
			{
				controlBarNode_ItemClickHandler(itemName)
				break;
			}
			case GraphEditorControlBar.DESTINATION_OBJECT_GRAPH_TRANSITION:
			{
				controlBarTransition_ItemClickHandler(itemName)
				break;
			}
			case GraphEditorControlBar.DESTINATION_OBJECT_GRAPH_CANVAS:
			default:
			{
				contextMenuSelectHandler(null, itemName)
				
				if (itemName == GraphEditorControlBar.ITEM_TYPE_DELETE)
					controlBarTransition_ItemClickHandler(itemName);
				
				break;
			}	
			
		}	
		
	}
	
	private function controlBarNode_ItemClickHandler (itemName : String) : void
	{
		if (!selectionManager)
			return;
		
		for each ( var obj : Object in selectionManager.selection )
		{
			if ( obj is Node )
			{
				Node(obj).controlBarItemClickHandler(itemName);
				
				if (itemName == "add_transition" || itemName == "jump" || itemName == "initial")
					break;
			}
		}

	}
	
	private function controlBarTransition_ItemClickHandler (itemName : String) : void
	{
		for each( var child : Object in getChildren() )
		{
			if ( child is Connector )
			{
				if (Connector(child).focused)
				{
					Connector(child).controlBarItemClickHandler(itemName);
					break;
				}
			}
		}
		
	}
	
	private function contextMenuSelectHandler( event : Event, itemName:String = "" ) : void
	{
		var contextMenuItemName : String = itemName;
		
		if (event)
			contextMenuItemName = event.target.name;
		
		switch ( contextMenuItemName )
		{
			case "add_state":
				selectionManager.deselectAll();
				createNode();
				break;

			case "add_command":
				selectionManager.deselectAll();
				createNode(NodeCategory.COMMAND);
				break;

			case "add_sub":
				selectionManager.deselectAll();
				createNode(NodeCategory.SUBGRAPH);
				break;

			case "add_resource":
				selectionManager.deselectAll();
				addResource();
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
			
			case "delete":
				alertDelete();
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
		DragManager.acceptDragDrop( UIComponent( event.target ) );
		DragManager.showFeedback( DragManager.MOVE );
	}

	private function dragDropHandler( event : DragEvent ) : void
	{
		var items : Array = event.dragSource.dataForFormat( "items" ) as Array;

		if ( !items || items.length <= 0 )
			return;

		if ( items[0] is XML )
		{
			var resourceXML : XML = items[0] as XML;

			addResourceNode(resourceXML.@ID);
		}
		else if ( items[0] is GraphCanvas )
		{
			var graph : GraphCanvas = items[0] as GraphCanvas;

			var nodeX : Number = event.localX + horizontalScrollPosition;
			var nodeY : Number = event.localY + verticalScrollPosition;

			createNode(NodeCategory.SUBGRAPH, nodeX, nodeY, true, false, graph.name);
		}

	}

	private function childRemoveHandler( event : ChildExistenceChangedEvent ) : void
	{
		event.relatedObject.addEventListener( GraphCanvasEvent.GRAPH_CHANGED, graphChangedHadler );
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

	private function get currentTemplate() : BuilderTemplate
	{
		return BuilderContextManager.currentTemplate;
	}
	
	public function findValue (value : String, useWholeWord : Boolean = false) : Array
	{
		var resultStatesArray : Array = [];
		
		value = value.replace("^", "\\^");
		value = value.replace("$", "\\$");
		value = value.replace(".", "\\.");
		value = value.replace("*", "\\*");
		value = value.replace("+", "\\+");
		value = value.replace("?", "\\?");
		value = value.replace("[", "\\[");
		value = value.replace("]", "\\]");
		value = value.replace("(", "\\(");
		value = value.replace(")", "\\)");
		value = value.replace("|", "\\|");
		value = value.replace("{", "\\{");
		value = value.replace("}", "\\}");
		
		var searchRegExp : RegExp;
		
		if (value.search(new RegExp("\\s", "m")) >= 0)
			useWholeWord = false;
			
		searchRegExp = useWholeWord ? new RegExp("(\\b|\\s)" + value + "(\\b|\\s)", "im") : new RegExp(value, "i");
		
		var graphXML : XML = toXML();
		
		if (!graphXML)
			return [];
		
		var stateText : String;
		
		for each (var graphState : XML in graphXML.states.state)
		{
			stateText = graphState.text[0];
			
			var index : int = stateText.search(searchRegExp);
			if (index >= 0)
			{
				var node : Object = {"name": graphState.@name, "text": stateText, "category": graphState.@category, "parentGraphName": name};
				
				resultStatesArray.push(node);
			}
		}
		
		return resultStatesArray;
		
	}
	
	public function getNodeByName( name : String ) : Node
	{
		var node : Node;
		var obj : Object = getChildByName( name );
			
		if ( obj && obj is Node )
			node = obj as Node;
	
		return node;
	}
	
	public function containsNodeInXml (nodeName:String) : Boolean
	{
		if (!xml)
			return false;
		
		for each (var stateXML : XML in xml.states.state)
		{
			if (stateXML.@name == nodeName)
				return true;
		}
		
		return false; 
	}
	
	public function get allVariables () : Array
	{
		var resultVariablesArray : Array = [];
		
		var variableRegExp : RegExp = /\$\w+/g;
		
		var graphXML : XML = toXML();
		
		if (!graphXML)
			return [];
		
		var stateText : String;
		
		var variables : Array = [];
		for each (var graphState : XML in graphXML.states.state)
		{
			stateText = graphState.text[0];
			
			variables = stateText.match(variableRegExp);
			
			if (!variables || variables.length == 0)
				continue;
			
			resultVariablesArray = resultVariablesArray.concat(variables);
		}
		
		resultVariablesArray = Utils.filterArrayUniqueValues(resultVariablesArray);
		
		resultVariablesArray.sort();

		return resultVariablesArray;
	}

}
}