package PowerPack.com.graph
{
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.ui.SuperNativeMenu;
import ExtendedAPI.com.ui.SuperNativeMenuItem;
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.managers.ContextManager;
import PowerPack.com.managers.LanguageManager;

import flash.display.DisplayObject;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.utils.Dictionary;

import mx.binding.utils.*;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.core.Application;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.managers.DragManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.ArrayUtil;
import mx.utils.NameUtil;

public class GraphCanvas extends Canvas
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
    	graph_paste_state:"Paste state", 
    	graph_clear:"Clear",
    	graph_expand_space:"Expand space",
    	graph_collapse_space:"Collapse space",    	
    	graph_alert_clear_title:"Confirmation",
    	graph_alert_clear_text:"Are you sure want to clear stage?" };
    
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
			
	[Bindable]
	override public function get name():String
    {
        return super.name;
    }			
	override public function set name(value:String):void
    {
    	if(super.name!=value)
    	{
        	super.name = value;
        	label = value;
     	}	
    }	    
    
	public var addingTransition:Boolean;
	public var currentArrow:Connector;		
	//public var initialNode:Node;
	public var category:String = "";
	
	public var initial:Boolean;
	
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
		
		//name = NameUtil.createUniqueName(this);
		
		addEventListener(DragEvent.DRAG_ENTER, dragEnterHandler); 
		addEventListener(DragEvent.DRAG_DROP, dragDropHandler);
		
		Application.application.addEventListener("copyNode", copyNodeHandler);		
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

		removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler); 
		removeEventListener(DragEvent.DRAG_DROP, dragDropHandler); 
		Application.application.removeEventListener("copyNode", copyNodeHandler);
   		
   		clear();
   		
        if(parent)
           	parent.removeChild(this);
           	
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
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

        if (ContextManager.FLASH_CONTEXT_MENU && !contextMenu)
        {
        	contextMenu = new SuperNativeMenu();
        	
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_add_state'], 'add_state'));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['graph_paste_state'], 'paste_state', false, null, false, Node.copyNode&&Node.copyNode.parent?true:false));
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
	
	//--------------------------------------------------------------------------
	//
	//  Methods
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
		
	public function clear():void
	{		
		var children:Array = getChildren();
		for each(var child:DisplayObject in children)
		{
			if(child is Connector)
				continue;
			else if(child is Node)
				(child as Node).dispose();
			else
				removeChild(child);
		}
		removeAllChildren();
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
	}
	
	public function expandSpace():void
	{
		var children:Array = getChildren();
		for each(var child:DisplayObject in children)
		{
			if(child is Node)
			{
				var node:Node = child as Node;
				if(node.y >= contentMouseY)
					node.y += node.height*2;		
			}
		}
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));	
	}
	
	public function collapseSpace():void
	{
		var children:Array = getChildren();
		for each(var child:DisplayObject in children)
		{
			if(child is Node)
			{
				var node:Node = child as Node;
				if(node.y >= contentMouseY)
					node.y -= node.height;		
			}
		}	
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
				newNode.validateProperties();
			}
		}
		
		if(newCanvas.parent)
		{
			newCanvas.validateNow();
		
			for each(var node:Node in newCanvas.getChildren()) {
				node.validateNow();
			}
		}
		
		for each (obj in getChildren())
		{
			if(obj is Connector)
			{
				var newArrow:Connector = Connector(obj).clone();
				
				newArrow.fromObject = dict[Connector(obj).fromObject];		
				newArrow.toObject = dict[Connector(obj).toObject];	
    			
    			newArrow.data = Node(newArrow.fromObject).arrTrans;
				newArrow.label = Connector(obj).label;
										
				if(newArrow.fromObject && newArrow.toObject)											
				{
					(newArrow.fromObject as Node).outArrows.addItem(newArrow);
					(newArrow.toObject as Node).inArrows.addItem(newArrow);
				
					newArrow.addEventListener(ConnectorEvent.DISPOSED, (newArrow.toObject as Node).destroyArrowHandler);
					BindingUtils.bindProperty(newArrow, 'data',
						newArrow.fromObject, 'arrTrans');
				
					newCanvas.addChildAt(newArrow, 0);
					
				}
			}	
		}				
				
		return newCanvas; 
	}
	
	public function createArrow(fromNode:Node, toNode:Node, label:String=null):void
	{
		var newArrow:Connector = new Connector();
				
		newArrow.fromObject = fromNode;		
		newArrow.toObject = toNode;	
		
		newArrow.data = Node(newArrow.fromObject).arrTrans;
		if(label)
			newArrow.label = label;
		
		addArrow(newArrow);
	}
	
	public function addArrow(arrow:Connector):void
	{
		if(arrow.fromObject && arrow.toObject)											
		{
			(arrow.fromObject as Node).outArrows.addItem(arrow);
			(arrow.toObject as Node).inArrows.addItem(arrow);
		
			arrow.addEventListener(ConnectorEvent.DISPOSED, (arrow.toObject as Node).destroyArrowHandler);
			
			BindingUtils.bindProperty(arrow, 'data',
				arrow.fromObject, 'arrTrans');
		
			addChildAt(arrow, 0);			
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
		category = graphXML.@category;
					
		for each (var nodeXML:XML in graphXML.states.elements("state"))
		{
			var newNode:Node = new Node(nodeXML.@category, nodeXML.@type, nodeXML.text);
			newNode.name = Utils.getStringOrDefault(nodeXML.@name, '');
			newNode.enabled = Utils.getBooleanOrDefault(nodeXML.@enabled);
			newNode.breakpoint = Utils.getBooleanOrDefault(nodeXML.@breakpoint); 
			newNode.x = Number(nodeXML.@x);
			newNode.y = Number(nodeXML.@y);
			
			addChild(newNode);
			
			newNode.validateProperties();
		}
		
		if(parent)
		{
			validateNow();
		
			for each(var node:Node in getChildren()) {
				node.validateNow();
			}
		}
		
		for each (var arrowXML:XML in graphXML.transitions.elements("transition"))
		{
			var newArrow:Connector = new Connector();				
			
			newArrow.fromObject = getChildByName(arrowXML.@source) as UIComponent;		
			newArrow.toObject = getChildByName(arrowXML.@destination) as UIComponent;
		
			if(newArrow.fromObject && Node(newArrow.fromObject).arrTrans && Node(newArrow.fromObject).arrTrans.length>0)
    		{
				if(ArrayUtil.getItemIndex(newArrow.label, Node(newArrow.fromObject).arrTrans)<0)
    			{
    				newArrow.data = Node(newArrow.fromObject).arrTrans;
					newArrow.label = newArrow.data[0];
    			}
    		}				
    		
			if(arrowXML.label.toString())
				newArrow.label = arrowXML.label;
			newArrow.enabled = Utils.getBooleanOrDefault(arrowXML.@enabled);
			newArrow.highlighted = Utils.getBooleanOrDefault(arrowXML.@highlighted);
				
			if(newArrow.fromObject && newArrow.toObject)											
			{
				(newArrow.fromObject as Node).outArrows.addItem(newArrow);
				(newArrow.toObject as Node).inArrows.addItem(newArrow);
			
				newArrow.addEventListener(ConnectorEvent.DISPOSED, (newArrow.toObject as Node).destroyArrowHandler);
				BindingUtils.bindProperty(newArrow, 'data',
					newArrow.fromObject, 'arrTrans');
			
				addChildAt(newArrow, 0);
			}
			
		}		
		
		dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));		
		return true;
	}		
	
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------		
    
	private function contextMenuSelectHandler(event:Event):void
	{
		switch(event.target.name)
		{
			case "add_state":
				var newNode:Node = new Node();		          
				addChild(newNode);			
				newNode.move(contentMouseX, contentMouseY);
				newNode.setFocus();
				dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
				break;
				
			case "paste_state":
				if(Node.copyNode) {
					var node:Node = Node.copyNode.duplicate(this);	
					node.setFocus();
					dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
				}
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
		newNode.move(event.localX + horizontalScrollPosition, 
			event.localY + verticalScrollPosition);
		newNode.setFocus();	    	
    }
    
    private function copyNodeHandler(event:Event):void
    {
    	contextMenu.getItemByName("paste_state").enabled =  Node.copyNode&&Node.copyNode.parent?true:false;
    }
		
}
}