package powerPack.com.graph
{
	import mx.controls.HRule;
	import mx.containers.Panel;
	import mx.core.Container;	
	
	import mx.containers.Canvas;
	import powerPack.com.graph.graphArrow;
	import mx.events.FlexEvent;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.styles.StyleManager;
	
	import mdm.Menu;
	import mx.utils.ArrayUtil;
	import mx.managers.SystemManager;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import powerPack.com.graph.PowerPackClass;	
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import mx.styles.CSSStyleDeclaration;
	import flash.display.DisplayObject;
	import mx.core.UIComponent;

	public class graphCanvas extends Canvas
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
	    
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
            
        // Define a static method.
        private static function classConstruct():Boolean 
        {
            if (!StyleManager.getStyleDeclaration("graphCanvas"))
            {
                // If there is no CSS definition for graphNode, 
                // then create one and set the default value.
                var newStyleDeclaration:CSSStyleDeclaration;
                
                if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("Canvas")))
                {
	                newStyleDeclaration = new CSSStyleDeclaration();
	                newStyleDeclaration.setStyle("themeColor", "haloBlue");
	            }        
	            
	           	// To get focus during clicking on canvas
	           	newStyleDeclaration.setStyle("backgroundColor", 0xffffff);
				newStyleDeclaration.setStyle("backgroundAlpha", 0.0);	
			        
                StyleManager.setStyleDeclaration("graphCanvas", newStyleDeclaration, true);
            }
            return true;
        }        	  
		//--------------------------------------------------------------------------
				
		public var addingTransition:Boolean = false;
		public var currentArrow:graphArrow;		
		private var contextMenuOld:ContextMenu = null; 
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/** 
		 *	Constructor
		 */		
		public function graphCanvas()
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
			//	
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

	        if (NEED_CONTEXT && !contextMenu)
	        {
	        	contextMenu = new ContextMenu();
	        	contextMenu.hideBuiltInItems();	        	
	        	
	        	contextMenu.customItems.push(new ContextMenuItem("Add State"));	
	        	contextMenu.customItems[0].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addStateHandler);
	        	contextMenu.customItems.push(new ContextMenuItem("Paste Node", false, 1||graphNode.copyNode&&graphNode.copyNode.parent?true:false));			
	        	contextMenu.customItems[1].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
	        	contextMenu.customItems.push(new ContextMenuItem("Clear"));			
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
				if(child is graphArrow)
					continue;
				else if(child is graphNode)
					(child as graphNode).destroy();
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
			
			graphXML.appendChild(<states></states>);
			graphXML.appendChild(<transitions></transitions>);
			
			for each(var child:DisplayObject in children)
			{
				if(child is graphArrow)
				{
					var arrow:graphArrow = child as graphArrow;
					var arrowXML:XML = new XML(<transition></transition>);
					arrowXML.@name = arrow.name;
					arrowXML.@highlight = arrow.highlight;
					arrowXML.@enabled = arrow.enabled;
					arrowXML.@source = arrow.fromObject.name;
					arrowXML.@destination = arrow.toObject.name;
					arrowXML.label = arrow.label;

					graphXML.transitions.appendChild(arrowXML);					
				}
				else if(child is graphNode)
				{
					var node:graphNode = child as graphNode;
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
						
			for each (var nodeXML:XML in graphXML.states.elements("state"))
			{
				var newNode:graphNode = new graphNode(nodeXML.@category, nodeXML.@type, nodeXML.text);
				newNode.name = nodeXML.@name;
				addChild(newNode);					
				newNode.enabled = nodeXML.@enabled;
				newNode.move(nodeXML.@x, nodeXML.@y);
			}
			createChildren();
			
			for each(var node:graphNode in getChildren())
			{
				node.validateNow();
			}
			
			for each (var arrowXML:XML in graphXML.transitions.elements("transition"))
			{
				var newArrow:graphArrow = new graphArrow();
				addChildAt(newArrow, 0);
				newArrow.fromObject = getChildByName(arrowXML.@source) as UIComponent;		
				newArrow.toObject = getChildByName(arrowXML.@destination) as UIComponent;
				
				if(newArrow.fromObject && newArrow.toObject)											
				{
					(newArrow.fromObject as graphNode).outArrows.addItem(newArrow);
					(newArrow.toObject as graphNode).inArrows.addItem(newArrow);
				
					newArrow.addEventListener("destroyArrow", (newArrow.toObject as graphNode).destroyArrowHandler);
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
			var newNode:graphNode = new graphNode();
			addChild(newNode);			
			newNode.move(mouseX, mouseY);
			newNode.setFocus();
		}
		
		private function pasteHandler(event:ContextMenuEvent):void
		{
			if(graphNode.copyNode)
			{
				var node:graphNode = graphNode.copyNode.duplicate(this);
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
	       	PowerPackClass.addMenuItemsByType("graphCanvas");

	     	/* mdm.Menu.Context.onContextMenuClick_Add_State = function():void{	
	     		var point:Point = new Point(Application.application.stage.mouseX, Application.application.stage.mouseY);
				var array:Array = Application.application.getObjectsUnderPoint(point);				
				
				mdm.Dialogs.prompt(array.length + ", " + array[array.length-1]);				
			}			

	     	mdm.Menu.Context.onContextMenuClick_Paste = function():void{
				mdm.Dialogs.prompt("Paste");				
			}	 */		
		}			
	}
}