package PowerPack.com.graph
{
	import mx.controls.HRule;
	import mx.containers.Panel;
	import mx.core.Container;	
	
	import mx.containers.Canvas;
	import PowerPack.com.graph.GraphArrow;
	import mx.events.FlexEvent;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.styles.StyleManager;
	
	import mdm.Menu;
	import mx.utils.ArrayUtil;
	import mx.managers.SystemManager;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import PowerPack.com.graph.PowerPackClass;	
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import mx.styles.CSSStyleDeclaration;
	import flash.display.DisplayObject;
	import mx.core.UIComponent;
	import mx.binding.utils.*;

	public class GraphCanvas extends Canvas
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------		
		
		private static const NEED_CONTEXT:Boolean = true;
		
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
				
		public var addingTransition:Boolean = false;
		public var currentArrow:GraphArrow;		
		public var initialNode:GraphNode;
    	
    	public var initial:Boolean = false;
		
		private var contextMenuOld:ContextMenu = null; 
				
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
			//TODO: implement function
			super();
			
			addEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
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
			removeEventListener(MouseEvent.MOUSE_OVER , mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT , mouseOutHandler);
       		
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
				
				for(var i:int=0; i<contextMenu.customItems.length; i++)
		    		contextMenu.customItems[i].caption = menuItemCaptions[i];   
	        }
	    }
	    					
		/**
	     *  Create child objects.
	     */
	    override protected function createChildren():void
	    {
	        super.createChildren();

	        if (NEED_CONTEXT && !contextMenu)
	        {
	        	contextMenu = new ContextMenu();
	        	contextMenu.hideBuiltInItems();	        	
	        	
	        	contextMenu.customItems.push(new ContextMenuItem(menuItemCaptions[0]));	
	        	contextMenu.customItems[0].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addStateHandler);
	        	contextMenu.customItems.push(new ContextMenuItem(menuItemCaptions[1], false, 1||GraphNode.copyNode&&GraphNode.copyNode.parent?true:false));			
	        	contextMenu.customItems[1].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
	        	contextMenu.customItems.push(new ContextMenuItem(menuItemCaptions[2]));			
	        	contextMenu.customItems[2].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearHandler);
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
			graphXML.@id = name;
			graphXML.@name = label;
			graphXML.@initial = initial.toString().toLowerCase();
			
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
			
			name = graphXML.@id;
			label = graphXML.@name;
			initial = graphXML.@initial.toString().toLowerCase()=="true"?true:false;
						
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
				addChildAt(newArrow, 0);
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
	    	PowerPackClass.refreshMenu(this);
	    	
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
	       	PowerPackClass.addMenuItemsByType("GraphCanvas");

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