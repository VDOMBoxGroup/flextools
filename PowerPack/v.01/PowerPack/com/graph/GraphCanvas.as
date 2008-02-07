package PowerPack.com.graph
{
	import PowerPack.com.CustomContextMenu;
	import PowerPack.com.Global;
	import PowerPack.com.mdm.*;
	
	import flash.display.DisplayObject;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mdm.Menu;
	
	import mx.binding.utils.*;
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.HRule;
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	import mx.managers.SystemManager;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.utils.ArrayUtil;
	import flash.events.Event;

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
		
		[Bindable]
	    [ArrayElementType("String")]
	    private var menuItemCaptions:Array = new Array(
	    	"Add State", 
	    	"Paste Node", 
	    	"Clear" );
	    	        	    
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
            
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
	           	newStyleDeclaration.setStyle("backgroundColor", 0xcccccc);
				newStyleDeclaration.setStyle("backgroundAlpha", 1.0);	
			        
                StyleManager.setStyleDeclaration("GraphCanvas", newStyleDeclaration, true);
            }
            return true;
        }    
	   	//--------------------------------------------------------------------------
        
        private var _langXML:XML;
        private var bLangXMLChanged:Boolean = false;	
        	   	    
        [Bindable]
	    public function set langXML(value:XML):void
	    {
	    	if(!value)
	    		return;
	    			    	
	        _langXML = value;
	        bLangXMLChanged = true;
	        
	        invalidateProperties();
	    }	
	    public function get langXML():XML
	    {
	        return _langXML;
	    }               	  
		//--------------------------------------------------------------------------
				
		[Bindable]
		override public function set name(value:String):void
	    {
	        super.name = value;
	        label = value;	
	    }
	    
	    
		public var addingTransition:Boolean = false;
		public var currentArrow:GraphArrow;		
		public var initialNode:GraphNode;
		public var category:String = "";
    	
    	public var initial:Boolean = false;
		
		private var contextMenuOld:ContextMenu = null; 
		private var customCM:CustomContextMenu;
				
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
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
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
		public function destroy():void
		{		
			if(customCM)
			{	
				customCM.clear();
	  		}			
			removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
			removeEventListener(DragEvent.DRAG_ENTER, dragEnterHandler); 
			removeEventListener(DragEvent.DRAG_DROP, dragDropHandler); 
			Application.application.removeEventListener("copyNode", copyNodeHandler);
       		
       		clear();
       		
	        if(parent)
        	{
   	        	parent.removeChild(this);
   	     	}
		}	
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
	    override protected function commitProperties():void
	    {
	        super.commitProperties();
	        	        
	        if (bLangXMLChanged)
	        {	        	
	        	bLangXMLChanged = false;

	        	menuItemCaptions = [];
	        	
		    	menuItemCaptions = new Array(
		    		langXML.graphcanvas.menuitemadd, 
		    		langXML.graphcanvas.menuitempaste, 
	    			langXML.graphcanvas.menuitemclear );	   
				
				for(var i:int=0; i<customCM.items.length; i++)
		    		customCM.items[i].name = menuItemCaptions[i];   
	        }
	    }
	    					
		/**
	     *  Create child objects.
	     */
	    override protected function createChildren():void
	    {
	        super.createChildren();

	        if (Global.FLASH_CONTEXT_MENU && !customCM)
	        {
	        	contextMenu = new ContextMenu();
	        	contextMenu.hideBuiltInItems();	
	        	
	        	customCM = new CustomContextMenu(contextMenu);        	
	        	
	        	customCM.addItem("add_state", menuItemCaptions[0], addStateHandler);
	        	customCM.addItem("paste_state", menuItemCaptions[1], pasteHandler, false, GraphNode.copyNode&&GraphNode.copyNode.parent?true:false);
	        	customCM.addItem("clear", menuItemCaptions[2], clearHandler);
	        }	        
	    }
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------	
		
		public function clear():void
		{		
			var children:Array = getChildren();
			for each(var child:DisplayObject in children)
			{
				if(child is GraphArrow)
					continue;
				else if(child is GraphNode)
					(child as GraphNode).destroy();
				else
					removeChild(child);
			}
			removeAllChildren();
		}
		
		// gen XML that represents graph structure
		public function toXML():XML
		{
			var graphXML:XML = new XML(<graph></graph>);
			var children:Array = getChildren();
			graphXML.@name = name;
			graphXML.@initial = initial.toString().toLowerCase();
			graphXML.@category = category;
			
			graphXML.appendChild(<states></states>);
			graphXML.appendChild(<transitions></transitions>);
			
			for each(var child:DisplayObject in children)
			{
				if(child is GraphArrow)
				{
					var arrow:GraphArrow = child as GraphArrow;
					var arrowXML:XML = new XML(<transition></transition>);
					arrowXML.@name = arrow.name;
					arrowXML.@highlight = arrow.highlight;
					arrowXML.@enabled = arrow.enabled;
					arrowXML.@source = arrow.fromObject.name;
					arrowXML.@destination = arrow.toObject.name;
					arrowXML.label = arrow.label;
					arrowXML.data = arrow.data;

					graphXML.transitions.appendChild(arrowXML);					
				}
				else if(child is GraphNode)
				{
					var node:GraphNode = child as GraphNode;
					var nodeXML:XML = new XML(<state></state>);
					nodeXML.@name = node.name;
					nodeXML.@type = node.type;
					nodeXML.@category = node.category;
					nodeXML.@enabled = node.enabled;	
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
			initial = graphXML.@initial.toString().toLowerCase()=="true"?true:false;
			category = graphXML.@category;
						
			for each (var nodeXML:XML in graphXML.states.elements("state"))
			{
				var newNode:GraphNode = new GraphNode(nodeXML.@category, nodeXML.@type, nodeXML.text);
				newNode.name = nodeXML.@name;
				BindingUtils.bindProperty(newNode, "langXML", this, "langXML");
				
				addChild(newNode);
				
				newNode.enabled = nodeXML.@enabled;
				newNode.move(nodeXML.@x, nodeXML.@y);
			}
			createChildren();
			
			for each(var node:GraphNode in getChildren())
			{
				node.validateNow();
			}
			
			for each (var arrowXML:XML in graphXML.transitions.elements("transition"))
			{
				var newArrow:GraphArrow = new GraphArrow();
				newArrow.langXML = langXML;
				BindingUtils.bindProperty(newArrow, "langXML", this, "langXML");				
				
				newArrow.fromObject = getChildByName(arrowXML.@source) as UIComponent;		
				newArrow.toObject = getChildByName(arrowXML.@destination) as UIComponent;
				newArrow.data = arrowXML.data;
				newArrow.label = arrowXML.label;
					
				if(newArrow.fromObject && newArrow.toObject)											
				{
					(newArrow.fromObject as GraphNode).outArrows.addItem(newArrow);
					(newArrow.toObject as GraphNode).inArrows.addItem(newArrow);
				
					newArrow.addEventListener("destroyArrow", (newArrow.toObject as GraphNode).destroyArrowHandler);
				}
				
				addChildAt(newArrow, 0);
			}				
			return true;
		}		
		
		//--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------		
	    			
		private function addStateHandler(event:ContextMenuEvent):void
		{
			var newNode:GraphNode = new GraphNode();
			newNode.langXML = langXML;
			BindingUtils.bindProperty(newNode, "langXML", this, "langXML");			          
			addChild(newNode);			
			newNode.move(mouseX, mouseY);
			newNode.setFocus();
		}
		
		private function pasteHandler(event:ContextMenuEvent):void
		{
			if(GraphNode.copyNode)
			{
				var node:GraphNode = GraphNode.copyNode.duplicate(this);				
				node.langXML = langXML;
				BindingUtils.bindProperty(node, "langXML", this, "langXML");
				node.setFocus();
			}
		}	

		private function clearHandler(event:ContextMenuEvent):void
		{
			clear();
		}
				
	    private function mouseOverHandler(event:MouseEvent):void
	    {	    	
	    	MDMContextMenu.refreshMenu(this);
	    	
			contextMenuOld = Application.application.contextMenu;
			if(contextMenu)
				Application.application.contextMenu = contextMenu;	
					    	
	    	event.stopPropagation();
	    }	
	    private function mouseOutHandler(event:MouseEvent):void
	    {
	    	if(contextMenuOld)
	    		Application.application.contextMenu = contextMenuOld;	    	
	    }  
	    
	    private function dragEnterHandler(event:DragEvent):void
	    {
            if (	event.dragSource.hasFormat("items") && 
		            event.dragSource.dataForFormat("items") &&
            		(event.dragSource.dataForFormat("items") as Array).length>0 &&
            		(event.dragSource.dataForFormat("items") as Array)[0] is GraphCanvas )
            {
                DragManager.acceptDragDrop(IUIComponent(event.target));
                DragManager.showFeedback(DragManager.MOVE);
            }	    	
	    }
	    private function dragDropHandler(event:DragEvent):void
	    {
	    	var items:Array = 
                    event.dragSource.dataForFormat("items") as Array;
	    	
	    	var graph:GraphCanvas = items[0] as GraphCanvas;
	    	
			var newNode:GraphNode = new GraphNode( GraphNodeCategory.SUBGRAPH, GraphNodeType.NORMAL, graph.name );
			newNode.langXML = langXML;
			BindingUtils.bindProperty(newNode, "langXML", this, "langXML");			          
			addChild(newNode);
			newNode.move(mouseX, mouseY);
			newNode.setFocus();	    	
	    }
	    
	    private function copyNodeHandler(event:Event):void
	    {
	    	customCM.getItemById("paste_state").contextMenuItem.enabled =  GraphNode.copyNode&&GraphNode.copyNode.parent?true:false;
	    }
		//--------------------------------------------------------------------------
	    //
	    //  For MDM Zinc integration
	    //
	    //--------------------------------------------------------------------------
	    
	    /**
	    * Generate context menu
	    */
		public static function generateContextMenu():void
		{
	       	MDMContextMenu.addMenuItemsByType("GraphCanvas");

	     	/*
	     	mdm.Menu.Context.onContextMenuClick_Add_State = function():void{	
	     		var point:Point = new Point(Application.application.stage.mouseX, Application.application.stage.mouseY);
				var array:Array = Application.application.getObjectsUnderPoint(point);				
				
				mdm.Dialogs.prompt(array.length + ", " + array[array.length-1]);				
			}			

	     	mdm.Menu.Context.onContextMenuClick_Paste = function():void{
				mdm.Dialogs.prompt("Paste");				
			}	 
			*/		
		}			
	}
}