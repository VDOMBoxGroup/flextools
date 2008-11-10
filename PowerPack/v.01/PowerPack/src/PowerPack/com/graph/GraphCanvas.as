package PowerPack.com.graph
{
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.ui.SuperNativeMenu;
import ExtendedAPI.com.ui.SuperNativeMenuItem;
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.managers.ContextManager;
import PowerPack.com.managers.LanguageManager;
import PowerPack.com.managers.SelectionManager;

import flash.desktop.Clipboard;
import flash.display.DisplayObject;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.binding.utils.*;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.UIComponent;
import mx.effects.Move;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.managers.DragManager;
import mx.managers.IFocusManagerComponent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.NameUtil;

public class GraphCanvas extends Canvas
	implements IFocusManagerComponent
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

    private static var defaultItemCaptions:Object = {
    	graph_add_state:"Add state", 
    	graph_cut:"Cut", 
    	graph_copy:"Copy", 
    	graph_paste:"Paste", 
    	graph_clear:"Clear",
    	graph_expand_space:"Expand space",
    	graph_collapse_space:"Collapse space",    	
    	graph_alert_clear_title:"Confirmation",
    	graph_alert_clear_text:"Are you sure want to clear stage?", 
    	graph_alert_delete_title:"Confirmation",
    	graph_alert_delete_text:"Are you sure want to delete seleted states?" 
    	};
    
    // Define a static variable.
    private static var _classConstructed:Boolean = classConstruct();
    
    public static function get classConstructed():Boolean
    {
    	return _classConstructed;
    }
        
    // Define a static method.
    private static function classConstruct():Boolean
    {
        if (!StyleManager.getStyleDeclaration("GraphCanvas"))
        {
            // If there is no CSS definition for GraphCanvas, 
            // then create one and set the default value.
            var newStyleDeclaration:CSSStyleDeclaration;
            
            if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("Canvas")))
            {
                newStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("themeColor", "haloBlue");
            }        
            
           	// To get focus during clicking on canvas
           	newStyleDeclaration.setStyle("backgroundColor", 0xdddddd);
			newStyleDeclaration.setStyle("backgroundAlpha", 1.0);	
		        
            StyleManager.setStyleDeclaration("GraphCanvas", newStyleDeclaration, true);
        }
        
        LanguageManager.setSentences(defaultItemCaptions);
        
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
		
		addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler); 
		addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
		addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		addEventListener("cut", onCut);
		addEventListener("copy", onCopy);
		addEventListener(MouseEvent.CONTEXT_MENU, contextMenuDisplayingHandler);	 
	}
	
	//--------------------------------------------------------------------------
	//
	//  Destructor
	//
	//--------------------------------------------------------------------------

	/**
	 *	Destructor
	 */ 
	public function dispose():void
	{		
		if(contextMenu)
		{	
        	contextMenu.removeEventListener(Event.SELECT, contextMenuSelectHandler);
        	SuperNativeMenu(contextMenu).dispose(); 	        	 
  		}	
  		
        if(selectionManager)
        {
        	selectionManager.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        	selectionManager.dispose();
        }  				

		removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler); 
		removeEventListener(DragEvent.DRAG_DROP, dragDropHandler); 
		removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		removeEventListener("cut", onCut);
		removeEventListener("copy", onCopy);
		removeEventListener(MouseEvent.CONTEXT_MENU, contextMenuDisplayingHandler);
   		
   		clear();
   		
        if(parent)
           	parent.removeChild(this);
           	
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	}	   

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  	 
    
    public var selectionManager:SelectionManager;
    
	public var addingTransition:Boolean;
	public var currentArrow:Connector;		
	
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  category
    //----------------------------------

	private var _category:String;
	private var _categoryChanged:Boolean;
	    			
	[Bindable("categoryChanged")]
	[Inspectable(category="General", defaultValue="other")]
	public function set category(value:String):void
    {
    	if(_category!=value)
    	{
	    	_category = value;
	    	
	        _categoryChanged = true;
	        
	        invalidateProperties();
	        
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.CATEGORY_CHANGED));
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
     	}	
    }	 
	public function get category():String
    {
        return _category;
    }	
    
    //----------------------------------
    //  initial
    //----------------------------------

	private var _initial:Boolean;
	private var _initialChanged:Boolean;
	    			
	[Bindable("initialChanged")]
	public function set initial(value:Boolean):void
    {
    	if(_initial!=value)
    	{
	    	_initial = value;
	    	
	        _initialChanged = true;
	        
	        invalidateProperties();
	        
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.INITIAL_CHANGED));
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
     	}	
    }	 
	public function get initial():Boolean
    {
        return _initial;
    }			
        
    //----------------------------------
    //  name
    //----------------------------------
    			
	[Bindable("nameChanged")]
	override public function set name(value:String):void
    {
    	if(super.name!=value)
    	{
        	super.name = value;
        	label = value;
        	
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.NAME_CHANGED));
	        dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));        	
     	}	
    }	    
	override public function get name():String
    {
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
    override protected function createChildren():void
    {
        super.createChildren();
        
        if(!selectionManager)
        {
        	selectionManager = new SelectionManager(this);
        	selectionManager.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        }

        if (ContextManager.FLASH_CONTEXT_MENU && !contextMenu)
        {
        	contextMenu = new SuperNativeMenu();
        	
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_add_state'], 'add_state'));
			contextMenu.addItem(new SuperNativeMenuItem('separator'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_cut'], 'cut', false, null, false, false));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_copy'], 'copy', false, null, false, false));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_paste'], 'paste', false, null, false, false));
			contextMenu.addItem(new SuperNativeMenuItem('separator'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_clear'], 'clear'));
			contextMenu.addItem(new SuperNativeMenuItem('separator'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_expand_space'], 'expand_space'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_collapse_space'], 'collapse_space'));
			
			for each (var item:NativeMenuItem in contextMenu.items) {
	       		//LanguageManager.bindSentence('graph_'+item.name, item);
			}
				
        	contextMenu.addEventListener(Event.SELECT, contextMenuSelectHandler);	        	 
        }	        
    }

    override protected function commitProperties():void
    {
        super.commitProperties();
    }
    	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------	

	public function alertClear():void
	{			
 		if(parent)
 		{
     		SuperAlert.show(
     			LanguageManager.sentences['graph_alert_clear_text'],
     			LanguageManager.sentences['graph_alert_clear_title'],
     			Alert.YES|Alert.NO, null, alertRemoveHandler, null, Alert.YES);			  
     	}
	}	
	
	public function alertDelete():void
	{			
 		if(parent)
 		{
     		SuperAlert.show(
     			LanguageManager.sentences['graph_alert_delete_text'],
     			LanguageManager.sentences['graph_alert_delete_title'],
     			Alert.YES|Alert.NO, null, alertDeleteHandler, null, Alert.YES);			  
     	}
	}	
		
	public function clear():void
	{		
		var children:Array = getChildren();
		for each(var child:DisplayObject in children)
		{
			if(child is Connector)
			{
				(child as Connector).removeEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
			}
			else if(child is Node)
			{
				(child as Node).removeEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
				(child as Node).dispose();
			}
			else
				removeChild(child);
		}
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	}
	
	public function expandSpace():void
	{
		var children:Array = getChildren();
		var arr:Array = [];
		
		for each(var child:DisplayObject in children)
		{
			if(child is Node)
			{
				var node:Node = child as Node;
				if(node.y >= contentMouseY)
				{
					node.endEffectsStarted();
					arr.push(node);			
				}		
			}
		}
		
		var move:Move = new Move();
		move.yBy = node.height*2;
		move.play(arr);
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));	
	}
	
	public function collapseSpace():void
	{
		var children:Array = getChildren();
		var arr:Array = [];
		
		for each(var child:DisplayObject in children)
		{
			if(child is Node)
			{
				var node:Node = child as Node;
				if(node.y >= contentMouseY)
				{
					node.endEffectsStarted();
					arr.push(node);	
				}
			}
		}	

		var move:Move = new Move();
		move.yBy = -node.height;
		move.play(arr);
				
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	}	
	
	public function clone():GraphCanvas
	{
		var newCanvas:GraphCanvas = new GraphCanvas();
		
		newCanvas.category = category;
		newCanvas.initial = initial;
		
		var dict:Dictionary = new Dictionary(true);
		for each (var obj:Object in getChildren())
		{
			if(obj is Node)
			{
				var newNode:Node = Node(obj).clone();				 
				dict[obj] = newNode; 
				newCanvas.addChild(newNode);
				newNode.addEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
			}
		}
		
		for each (obj in getChildren())
		{
			if(obj is Connector)
			{
				var newArrow:Connector = Connector(obj).clone();
				
				newArrow.fromObject = dict[Connector(obj).fromObject];		
				newArrow.toObject = dict[Connector(obj).toObject];	
    			
				addArrow(newArrow, newCanvas);
			}	
		}				
				
		return newCanvas; 
	}
	
	public function createNode(x:Number=NaN, y:Number=NaN, focused:Boolean=true):Node
	{
		var newNode:Node = new Node();		          
		
		addChild(newNode);			
		
		newNode.move(isNaN(x)?contentMouseX:x, isNaN(y)?contentMouseY:y);
		
		if(focused)
			newNode.setFocus();
		
		newNode.addEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
		
		return newNode;
	}
	
	public function createArrow(fromNode:Node, toNode:Node, label:String=null):Connector
	{
		var newArrow:Connector = new Connector();
				
		newArrow.fromObject = fromNode;		
		newArrow.toObject = toNode;	
		
		newArrow.label = label;
		if(newArrow.fromObject)
			newArrow.data = Node(newArrow.fromObject).arrTrans;
		
		addArrow(newArrow);
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
		
		return newArrow;
	}
	
	private function addArrow(arrow:Connector, canvas:GraphCanvas=null):void
	{
		if(arrow.fromObject && arrow.toObject)											
		{
			(arrow.fromObject as Node).outArrows.addItem(arrow);
			(arrow.toObject as Node).inArrows.addItem(arrow);
		
			BindingUtils.bindProperty(arrow, 'data',
				arrow.fromObject, 'arrTrans');
			
			if(canvas)
				canvas.addChildAt(arrow, 0);
			else
				addChildAt(arrow, 0);
				
			arrow.addEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
		}		
	}
	
	// gen XML that represents graph structure
	public function toXML():XML
	{
		var graphXML:XML = new XML(<graph/>);
		var children:Array = getChildren();
		
		graphXML.@name = name;
		graphXML.@initial = initial.toString().toLowerCase();
		graphXML.@category = category;
		
		graphXML.appendChild(<states/>);
		graphXML.appendChild(<transitions/>);
		
		for each(var child:DisplayObject in children)
		{
			if(child is Connector)
			{
				var arrow:Connector = child as Connector;
				var arrowXML:XML = new XML(<transition/>);
				arrowXML.@name = arrow.name;
				arrowXML.@highlighted = arrow.highlighted;
				arrowXML.@enabled = arrow.enabled;
				arrowXML.@source = arrow.fromObject.name;
				arrowXML.@destination = arrow.toObject.name;
				if(arrow.label)
					arrowXML.label = arrow.label;

				graphXML.transitions.appendChild(arrowXML);					
			}
			else if(child is Node)
			{
				var node:Node = child as Node;
				var nodeXML:XML = new XML(<state/>);
				nodeXML.@name = node.name;
				nodeXML.@type = node.type;
				nodeXML.@category = node.category;
				nodeXML.@enabled = node.enabled;	
				nodeXML.@breakpoint = node.breakpoint;	
				nodeXML.@x = node.x;
				nodeXML.@y = node.y;
				nodeXML.text = node.text;

				graphXML.states.appendChild(nodeXML);					
			}
		}
		return graphXML;
	}
	
	// gen graph from XML
	public function fromXML(strXML:String):Boolean
	{			
		var graphXML:XML = new XML(strXML);
		
		clear();
		
		name = graphXML.@name;
		initial = Utils.getBooleanOrDefault(graphXML.@initial); 
		category = Utils.getStringOrDefault(graphXML.@category, 'other');
					
		for each (var nodeXML:XML in graphXML.states.elements("state"))
		{
			var newNode:Node = new Node(nodeXML.@category, nodeXML.@type, nodeXML.text);
			newNode.name = Utils.getStringOrDefault(nodeXML.@name, NameUtil.createUniqueName(newNode));
			newNode.enabled = Utils.getBooleanOrDefault(nodeXML.@enabled);
			newNode.breakpoint = Utils.getBooleanOrDefault(nodeXML.@breakpoint); 
			newNode.x = Number(nodeXML.@x);
			newNode.y = Number(nodeXML.@y);
			
			addChild(newNode);
			
			newNode.addEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
		}
		
		for each (var arrowXML:XML in graphXML.transitions.elements("transition"))
		{
			var newArrow:Connector = createArrow(	
							getChildByName(arrowXML.@source) as Node,
							getChildByName(arrowXML.@destination) as Node,
							Utils.getStringOrDefault(arrowXML.label));

			newArrow.enabled = Utils.getBooleanOrDefault(arrowXML.@enabled);
			newArrow.highlighted = Utils.getBooleanOrDefault(arrowXML.@highlighted);
		}		
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));	
			
		return true;
	}		
	
    public function doCopy():void
    {
    	if(selectionManager && selectionManager.getSelection().length>0)
    	{
			var dataXML:XML = new XML(<copy/>);
			var outArrows:Dictionary = new Dictionary(true);
			var inArrows:Dictionary = new Dictionary(true);
			
			for each(var obj:Object in selectionManager.getSelection())
			{
				if(obj is Node)
				{
					dataXML.appendChild(Node(obj).toXML());
					
					for each(var _out:Connector in Node(obj).outArrows)
						outArrows[_out] = true;

					for each(var _in:Connector in Node(obj).inArrows)
						inArrows[_in] = true;
				}
			}
			
			for each(var arrow:Object in getChildren())
			{
				if(arrow is Connector && outArrows[arrow] && inArrows[arrow])
				{
					dataXML.appendChild(Connector(arrow).toXML());
				}
			}
			
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData("GRAPH_FORMAT", dataXML);
    	}
    }

    public function doPaste():void
    {
		if(Clipboard.generalClipboard.hasFormat("GRAPH_FORMAT"))
		{
			selectionManager.deselectAll();
			
			var dataXML:XML = XML(Clipboard.generalClipboard.getData("GRAPH_FORMAT"));
			var namesMap:Object = new Object(); 
			    		
    		for each(var xmlNode:XML in dataXML.state)
    		{
				var newNode:Node = Node.fromXML(xmlNode);
				namesMap[newNode.name] = NameUtil.createUniqueName(newNode);
				newNode.name = namesMap[newNode.name];
				newNode.selected = true;
				addChild(newNode);			
				newNode.addEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);				
    		}
    		
    		for each(var xmlArrow:XML in dataXML.transition)
    		{
				var newArrow:Connector = createArrow(	
							getChildByName(namesMap[xmlArrow.@source]) as Node,
							getChildByName(namesMap[xmlArrow.@destination]) as Node,
							Utils.getStringOrDefault(xmlArrow.label));			
			
				newArrow.enabled = Utils.getBooleanOrDefault(xmlArrow.@enabled);
				newArrow.highlighted = Utils.getBooleanOrDefault(xmlArrow.@highlighted);
    		}
    		    		
    		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
		}		  	
    }
    
	public function doSelectAll():void
    {
    	setFocus();
    	
    	if(selectionManager)
    		selectionManager.selectAll();
    }

	public function doCut():void
	{
		doCopy();
		doDelete();
	}
	
	public function doDelete():void
	{
		var children:Array = getChildren();
		for each(var child:Object in children)
		{
			if(child is Connector)
			{
				child.removeEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
			}
			else if(child.hasOwnProperty('selected') && child.selected)
			{
				child.removeEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
				child.dispose();
			}
		}
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));		
	}
	
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------		
	
	private function onKeyDown(event:KeyboardEvent):void
    {
		if(event.keyCode == Keyboard.DELETE)
     	{
	    	event.stopPropagation();
	    	
	    	if(selectionManager && selectionManager.getSelection().length>0)
	    		alertDelete();
	    }
	    else if(event.controlKey || event.commandKey)
	    {
	    	if(event.keyCode == Keyboard.X)
	    	{
	    		event.stopPropagation();
	    		doCut();
	    	}
	    	else if(event.keyCode == Keyboard.C)
	    	{
	    		event.stopPropagation();
	    		doCopy();
	    	}
	    	else if(event.keyCode == Keyboard.V)
	    	{
	    		event.stopPropagation();
	    		doPaste();	
	    	}
	    }
	    
	}
	
	private function contextMenuDisplayingHandler(event:Event):void
	{
		if(selectionManager && selectionManager.getSelection().length>0)
		{
			contextMenu.getItemByName("cut").enabled = true;	
			contextMenu.getItemByName("copy").enabled = true;
		}
		else
		{
			contextMenu.getItemByName("cut").enabled = false;	
			contextMenu.getItemByName("copy").enabled = false;			
		}
		
		if(Clipboard.generalClipboard.hasFormat("GRAPH_FORMAT"))
		{
			contextMenu.getItemByName("paste").enabled = true;	
		}
		else
		{
			contextMenu.getItemByName("paste").enabled = false;
		}	
	}
	    
    private function onCopy(event:Event):void
    {
    	doCopy();	
    }
    
    private function onCut(event:Event):void
    {
    	doCut();	
    }

	private function contextMenuSelectHandler(event:Event):void
	{
		switch(event.target.name)
		{
			case "add_state":
				createNode();
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
	
    private function alertRemoveHandler(event:CloseEvent):void 
    {
    	if(event.detail==Alert.YES)
    	{        		
   			clear();
        }
	}	
    
    private function alertDeleteHandler(event:CloseEvent):void 
    {
    	if(event.detail==Alert.YES)
    	{        		
   			doDelete();
        }
	}
	    
    private function dragEnterHandler(event:DragEvent):void
    {
        if (	event.dragSource.hasFormat("items") && 
	            event.dragSource.dataForFormat("items") &&
        		(event.dragSource.dataForFormat("items") as Array).length>0 &&
        		(event.dragSource.dataForFormat("items") as Array)[0] is GraphCanvas )
        {
            DragManager.acceptDragDrop(UIComponent(event.target));
            DragManager.showFeedback(DragManager.MOVE);
        }	    	
    }
    
    private function dragDropHandler(event:DragEvent):void
    {
    	var items:Array = 
                event.dragSource.dataForFormat("items") as Array;
    	
    	var graph:GraphCanvas = items[0] as GraphCanvas;
    	
		var newNode:Node = new Node( NodeCategory.SUBGRAPH, NodeType.NORMAL, graph.name );
		addChild(newNode);
		newNode.move(	event.localX + horizontalScrollPosition, 
						event.localY + verticalScrollPosition);
		newNode.setFocus();
		
		newNode.addEventListener(GraphCanvasEvent.GRAPH_CHANGED, onGraphChanged);
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));	    	
    }
    
    private function onGraphChanged(event:GraphCanvasEvent):void
    {
    	event.stopImmediatePropagation();
    	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
    }
    
}
}