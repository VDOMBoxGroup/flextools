package PowerPack.com.graph
{
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mdm.Menu;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.IFocusManagerComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.managers.PopUpManager;
	import mx.controls.ComboBox;
	import mx.events.DropdownEvent;
	import mx.core.Container;
	
	[Style(name="color", type="uint", format="Color", inherit="yes")]
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
	[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
	[Style(name="highlightColor", type="uint", format="Color", inherit="yes")]
	[Style(name="disabledColor", type="uint", format="Color", inherit="yes")]
	[Style(name="alpha", type="Number", format="Length", inherit="yes")]	
	//[Style(name="strokeWidth", type="Number", format="Length", inherit="no")]
	[Style(name="arrowSize", type="Number", format="Length", inherit="no")]
	[Style(name="arrowAngle", type="Number", format="Length", inherit="no")]
	
	[Style(name="focusRollOverColor", type="uint", format="Color", inherit="no")]
	[Style(name="focusSelectionColor", type="uint", format="Color", inherit="no")]
	[Style(name="focusHighlightColor", type="uint", format="Color", inherit="no")]
	[Style(name="focusAlpha", type="Number", format="Length", inherit="no")]
	[Style(name="focusThickness", type="Number", format="Length", inherit="no")]
	
	[Event(name="enabledChanged", type="flash.events.Event")]
	[Event(name="dataChanged", type="flash.events.Event")]	
	[Event(name="labelChanged", type="flash.events.Event")]	
	[Event(name="highlightChanged", type="flash.events.Event")]	
	[Event(name="fromObjectChanged", type="flash.events.Event")]	
	[Event(name="destroyArrow", type="flash.events.Event")]		
	
	public class GraphArrow extends UIComponent implements IFocusManagerComponent
	{
		//--------------------------------------------------------------------------
	    //
	    //  Class constants
	    //
	    //--------------------------------------------------------------------------
	    
	    private static const SELECT_AREA_SIZE:int = 5;
	    private static const NEED_CONTEXT:Boolean = true;
	    		
	    //--------------------------------------------------------------------------
	    //
	    //  Variables and properties
	    //
	    //--------------------------------------------------------------------------	
	     
	    [Bindable]
	    private var alertDeleteTitle:String = "Confirmation";
	    [Bindable]
	    private var alertDeleteText:String = "Are you sure want to delete this arrow?";
	    [Bindable]
	    private var defaultLbl:String = "Arrow";

		[Bindable]
	    [ArrayElementType("String")]
	    private var menuItemCaptions:Array = new Array(
	    	"Select Transition",
	    	"Delete Arrow", 
	    	"Enable Arrow", 
	    	"Highlight Arrow" );
	    	        	    	        
        // Define a static variable.
        private static var classConstructed:Boolean = classConstruct();
            
        // Define a static method.
        private static function classConstruct():Boolean 
        {
            if (!StyleManager.getStyleDeclaration("GraphArrow"))
            {
                // If there is no CSS definition for GraphArrow, 
                // then create one and set the default value.
                var newStyleDeclaration:CSSStyleDeclaration;
                
                if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("UIComponent")))
                {
	                newStyleDeclaration = new CSSStyleDeclaration();
	                newStyleDeclaration.setStyle("themeColor", "haloBlue");
	            }

                newStyleDeclaration.setStyle("color", 0x000000);
                newStyleDeclaration.setStyle("rollOverColor", 0x333333);
                newStyleDeclaration.setStyle("selectionColor", 0x000000);
                newStyleDeclaration.setStyle("highlightColor", 0xffffff);
                newStyleDeclaration.setStyle("disabledColor",  0x666666);
                
                newStyleDeclaration.setStyle("alpha", 1);
                newStyleDeclaration.setStyle("strokeWidth", 1);
                newStyleDeclaration.setStyle("arrowSize", 8);
                newStyleDeclaration.setStyle("arrowAngle", 60);
                
                newStyleDeclaration.setStyle("focusThickness", 2);
                newStyleDeclaration.setStyle("focusRollOverColor", newStyleDeclaration.getStyle("themeColor"));
                newStyleDeclaration.setStyle("focusSelectionColor", newStyleDeclaration.getStyle("themeColor"));
                newStyleDeclaration.setStyle("focusHighlightColor", newStyleDeclaration.getStyle("themeColor"));                
                newStyleDeclaration.setStyle("focusAlpha", 0.4);
                
                StyleManager.setStyleDeclaration("GraphArrow", newStyleDeclaration, true);
            }
            return true;
        }        	  
		//--------------------------------------------------------------------------     
		
	    private var bOver:Boolean = false;
	    private var bChanged:Boolean = false;	
	    private var contextMenuOld:ContextMenu = null; 

	    [ArrayElementType("Point")]
	    private var arrPolygon:Array; 
	    
	    private var nWidth:Number = 0;
	    private var nHeight:Number = 0;

	    private var nTop:Number = 0;
	    private var nRight:Number = 0;
	    private var nBottom:Number = 0;
	    private var nLeft:Number = 0;
	    
		//--------------------------------------------------------------------------
		
	    private var bFocused:Boolean = false;
	    
	    public function get focused():Boolean
	    {
	    	if(this.getFocus()==this)
	    		bFocused = true;
	    	else 
	    		bFocused = false;
	    	
	        return bFocused;
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
	   	
	    private var bHighlighted:Boolean = false;
    	private var bHighlightChanged:Boolean = false;
    	
	    [Bindable("highlightChanged")]
	    [Inspectable(category="General", defaultValue=false)]
	
	    public function set highlight(value:Boolean):void
	    {
	        bHighlighted = value;
	        bHighlightChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("highlightChanged"));
	    }
	    public function get highlight():Boolean
	    {
	        return bHighlighted;
	    }	
	   	//--------------------------------------------------------------------------
	   	    
	    private var bEnabled:Boolean = true;
    	private var bEnabledChanged:Boolean = false;
    	
	    [Bindable("enableChanged")]
	    [Inspectable(category="General", defaultValue=true)]
	
	    override public function set enabled(value:Boolean):void
	    {
	    	super.enabled = value;
	    	
	        bEnabled = value;
	        bEnabledChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("enabledChanged"));
	    }	
	    override public function get enabled():Boolean
	    {
	        return bEnabled;
	    }   
	    //--------------------------------------------------------------------------    
	    
	    private var strLabel:String;
	    private var bLabelChanged:Boolean = false;	    
    	
	    [Bindable("labelChanged")]
	    [Inspectable(category="General", defaultValue=defaultLbl)]
	
	    public function set label(value:String):void
	    {
	        strLabel = value;
	        bLabelChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("labelChanged"));
	    }
	    public function get label():String
	    {
	        return strLabel;
	    }	     
	    //--------------------------------------------------------------------------    
	    
	    private var objData:Object;

	    [Bindable("dataChanged")]
	    [Inspectable(category="General")]
	
	    public function set data(value:Object):void
	    {
	        objData = value;	         
	        dispatchEvent(new Event("dataChanged"));
	    }
	    public function get data():Object
	    {
	        return objData;
	    }
	    //--------------------------------------------------------------------------	    
	    
		private var fromObj:UIComponent = null;
	    private var bFromObjChanged:Boolean = false;	    
    	
	    [Bindable("fromObjectChanged")]
	
	    public function set fromObject(value:UIComponent):void
	    {
	        fromObj = value;
	        bFromObjChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("fromObjectChanged"));
	    }
	    public function get fromObject():UIComponent
	    {
	        return fromObj;
	    }
	    //--------------------------------------------------------------------------
	    		
		private var toObj:UIComponent = null;	
	    private var bToObjChanged:Boolean = false;	    
    	
	    [Bindable("toObjectChanged")]
	
	    public function set toObject(value:UIComponent):void
	    {
	        toObj = value;
	        bToObjChanged = true;
	        
	        invalidateProperties();
	        invalidateSize();
	        invalidateDisplayList();
	         
	        dispatchEvent(new Event("toObjectChanged"));
	    }	
	    public function get toObject():UIComponent
	    {
	        return toObj;
	    }	
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/** 
		 *	Constructor
		 */
		public function GraphArrow()
		{
			super();
			
			label = defaultLbl;
			doubleClickEnabled = true;
			focusEnabled = true;
			mouseFocusEnabled = true;
			tabEnabled = false;	
			styleName = this.className;	
			cacheAsBitmap = true;
			
           	addEventListener(FlexEvent.ADD, addHandler);
           	addEventListener(FocusEvent.FOCUS_IN, graphArrow_focusInHandler);	
           	addEventListener(FocusEvent.FOCUS_OUT, graphArrow_focusOutHandler);
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
			if(contextMenu)
			{	
				if(contextMenu.customItems.length>0)
					contextMenu.customItems[0].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectTransHandler);
				if(contextMenu.customItems.length>1)
					contextMenu.customItems[1].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteArrowHandler);
				if(contextMenu.customItems.length>2)
		        	contextMenu.customItems[2].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, enableHandler);
				if(contextMenu.customItems.length>3)
		        	contextMenu.customItems[3].removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, highlightHandler);
	  		}	
	  				
	  		stopDragging();
   			
            removeEventListener(FlexEvent.ADD, addHandler);
            systemManager.removeEventListener(KeyboardEvent.KEY_DOWN, systemManager_keyDown);            
   			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
            removeEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
           	removeEventListener(FocusEvent.FOCUS_IN, graphArrow_focusInHandler);	
           	removeEventListener(FocusEvent.FOCUS_OUT, graphArrow_focusOutHandler);

	        if(parent)
        	{
   	        	parent.removeChild(this);
   	     	}
   	        	
	       	dispatchEvent(new Event("destroyArrow"));
		}	
			
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------	
		
		// Override styleChanged() to detect changes in your new style.
        override public function styleChanged(styleProp:String):void 
        {
            super.styleChanged(styleProp);

            bChanged=true; 
            invalidateDisplayList();
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
	        	
	        	contextMenu.customItems.push(new ContextMenuItem(menuItemCaptions[0], false, true, false));	
	        	contextMenu.customItems[0].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectTransHandler);	        	
	        	contextMenu.customItems.push(new ContextMenuItem(menuItemCaptions[1], false, true, false));	
	        	contextMenu.customItems[1].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteArrowHandler);
	        	contextMenu.customItems.push(new ContextMenuItem((bEnabled?"· ":"") + menuItemCaptions[2], false, true, false));			
	        	contextMenu.customItems[2].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, enableHandler);
	        	contextMenu.customItems.push(new ContextMenuItem((bHighlighted?"· ":"") + menuItemCaptions[3], false, true, false));			
	        	contextMenu.customItems[3].addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, highlightHandler);
	        }	        
	    }

	    override protected function commitProperties():void
	    {
	        super.commitProperties();
	        	        
	        if (bLangXMLChanged)
	        {	        	
	        	bLangXMLChanged = false;

				alertDeleteTitle = langXML.grapharrow.alertdeletetitle;
				alertDeleteText = langXML.grapharrow.alertdeletetext;
				defaultLbl = langXML.grapharrow.defaultlabel;

	        	bEnabledChanged = true;
	        	bHighlightChanged = true;
	        	
	        	menuItemCaptions = [];
	        	
		    	menuItemCaptions = new Array(
		    		langXML.grapharrow.menuitemselecttrans, 
		    		langXML.grapharrow.menuitemdelete, 
	    			langXML.grapharrow.menuitemenable, 
	    			langXML.grapharrow.menuitemhighlight );	   
				
				for(var i:int=0; i<contextMenu.customItems.length; i++)
		    		contextMenu.customItems[i].caption = menuItemCaptions[i];   
	        }
	        if (bEnabledChanged)
	        {
	            bEnabledChanged = false;
	            if(contextMenu && contextMenu.customItems.length>0)
		            contextMenu.customItems[2].caption = (bEnabled?"· ":"") + menuItemCaptions[2];
	            bChanged = true;
	        }	
	        if (bHighlightChanged)
	        {
	            bHighlightChanged = false;
	            if(contextMenu && contextMenu.customItems.length>1)
		            contextMenu.customItems[3].caption = (bHighlighted?"· ":"") + menuItemCaptions[3];
	            bChanged = true;
	        }
	        if (bLabelChanged)
	        {
	            bLabelChanged = false;
	            bChanged = true;
	            
	            toolTip = strLabel;
	        }	 
	        
	        if(!fromObj || !toObj)
	        {
        		removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	            removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	            removeEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
	            
	            if(contextMenu)
	            {
	            	for each (var menuItem:ContextMenuItem in contextMenu.customItems)
		            	menuItem.visible = false;
	            }	
	        }
	        else
	        {
        		addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	            addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	            addEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
            
	            if(contextMenu)
	            {
	            	for each (menuItem in contextMenu.customItems)
		            	menuItem.visible = true;
	            }	
	        }	        
	        
	        if (bFromObjChanged)
	        {
	            bFromObjChanged = false;
	            bChanged = true;
			
				if(fromObj && !toObj && parent)
				{		
					stopDragging();		
					startDragging();	           		
				}			            
	        }	 
	        if (bToObjChanged)
	        {
	            bToObjChanged = false;
	            bChanged = true;
			
				if(toObj && parent)
				{					
					stopDragging();
					beginEdit((parent as Container).contentToGlobal(new Point(x+width/2, y+height/2)));       		
				}	            
	        }	 	  
	              
            if(bChanged)
            {
            	if(parent)
		            calcSize();	            
            }                   
	                      
            if (initialized)
            {
                invalidateSize();
        		invalidateDisplayList();
            }	        		        
	    } 
	    
		override protected function measure():void {
            super.measure();
                        
            measuredWidth = nWidth; 
            measuredHeight = nHeight;                    
        }  	    		
   
		// Override updateDisplayList() to update the component 
		override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);	
            
            if(bChanged==true)
            { 
            	bChanged = false;
            	move(nLeft, nTop);
            	setActualSize(nWidth, nHeight);
            	
				drawArrows();
            }
		}
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
					
		public function alertDestroy():void
		{			
     		if(parent)
     		{
	     		Alert.show(alertDeleteText, alertDeleteTitle, Alert.YES|Alert.NO, this, alertRemoveHandler, null, Alert.NO);			     	
	     	}
		}	
				
		private function calcSize():void
		{
			if(!arrPolygon)
				arrPolygon = new Array();
			
			while(arrPolygon.length)
				arrPolygon.pop();
			
			var _pFromObj:Point;
			var _pToObj:Point;
			var pFromObj:Point;
			var pToObj:Point;
			var pArrow1:Point;
			var pArrow2:Point;
			
    		var fromObjWidth:Number = 0;
    		var fromObjHeight:Number = 0;
    		var fromObjHalfWidth:Number = 0;
    		var fromObjHalfHeight:Number = 0;

   			var toObjWidth:Number = 0;
   			var toObjHeight:Number = 0;			
   			var toObjHalfWidth:Number = 0;
   			var toObjHalfHeight:Number = 0;	
   						
			var fromObjVertCross:Boolean = false;
			var toObjVertCross:Boolean = false;
			
			if(fromObj)
			{
				/**
				 * Calculates fromObject center coordinates   
				 */			
    			fromObjWidth = fromObj.width;
    			fromObjHeight = fromObj.height;
    			fromObjHalfWidth = fromObjWidth/2;
    			fromObjHalfHeight = fromObjHeight/2;
    						 	
				_pFromObj = new Point( 
					fromObj.x+fromObjHalfWidth, 
					fromObj.y+fromObjHalfHeight );
   			}
   			   			
   			if(toObj)
   			{
				/**
				 * Calculates toObject center coordinates   
				 */	
   				toObjWidth = toObj.width;
   				toObjHeight = toObj.height;			
   				toObjHalfWidth = toObjWidth/2;
   				toObjHalfHeight = toObjHeight/2;					 				 
   				
				_pToObj = new Point( 
					toObj.x+toObjHalfWidth,
   					toObj.y+toObjHalfHeight );
   			}
			else
			{
				/**
				 * Gets mouse position coordinates if adding transition
				 */
				_pToObj = new Point( 
		   			parent.mouseX,
		   			parent.mouseY );
			}
			
			if(_pFromObj)
				pFromObj = new Point( _pFromObj.x, _pFromObj.y );
			if(_pToObj)
				pToObj = new Point( _pToObj.x, _pToObj.y );
			
			if(fromObj)
			{
				var arrowWidth:Number = Math.abs( pToObj.x - pFromObj.x );
    			var arrowHeight:Number = Math.abs( pToObj.y - pFromObj.y );				

    			var koef:Number = arrowWidth/arrowHeight;
    			var fromObjKoef:Number = fromObjWidth/fromObjHeight;

    			var toObjKoef:Number = 0;
	   			if(toObj)
   				{
	    			toObjKoef = toObjWidth/toObjHeight;
    			}
				
				/**
				 * If objects overlay each other then return from function 
				 */				 
				if(arrowWidth<=fromObjHalfWidth+toObjHalfWidth && arrowHeight<=fromObjHalfHeight+toObjHalfHeight)
   					return;  					

				var dX:Number = 0;
				var dY:Number = 0;
				
				/**
				 * If koef > fromObjKoef then arrow crosses vertical border of fromObject else - horisontal
				 */
   				if( koef > fromObjKoef )
    				fromObjVertCross = true;

				/**
				 * Calculates delta X and delta Y for arrow start point
				 */
				if(fromObjVertCross)
				{
					dX = fromObjHalfWidth;
					dY = dX/koef;
				}
				else
				{
					dY = fromObjHalfHeight;
					dX = dY*koef;
				}  
				
				if( pFromObj.x < pToObj.x ) 	{ pFromObj.x+=dX; }
   				else 							{ pFromObj.x-=dX; }    					
					
   				if( pFromObj.y < pToObj.y ) 	{ pFromObj.y+=dY; }    					
   				else							{ pFromObj.y-=dY; }

    			if(toObj)
   				{	    			
	   				if( koef > toObjKoef )
	    				toObjVertCross = true;
					/**
					 * Calculates delta X and delta Y for arrow end point
					 */	 
					if(toObjVertCross)
					{
						dX = toObjHalfWidth;
						dY = dX/koef;
					}
					else
					{
						dY = toObjHalfHeight;
						dX = dY*koef;
					}  
					
					if( pFromObj.x < pToObj.x ) 	{ pToObj.x-=dX; }
	   				else 							{ pToObj.x+=dX; }    					
						
	   				if( pFromObj.y < pToObj.y ) 	{ pToObj.y-=dY; }    					
	   				else							{ pToObj.y+=dY; }					    				
    			}
    			
    			/**
    			 * Arrow pointer
    			 */ 
									
				var angle:Number = Math.atan2( pFromObj.y-pToObj.y, pFromObj.x-pToObj.x );				
				var dAngle:Number = (getStyle("arrowAngle")/2) * Math.PI/180;				
				var dLen:Number = getStyle("arrowSize");

				pArrow1 = Point.polar( dLen, angle+dAngle );
				pArrow1.offset( pToObj.x, pToObj.y );
				pArrow2 = Point.polar( dLen, angle-dAngle );	
				pArrow2.offset( pToObj.x, pToObj.y );				
    			
    			/**
    			 *  Fill in polygon array
    			 */				
				nLeft = Math.min(pFromObj.x, pToObj.x, pArrow1.x, pArrow2.x)-getStyle("strokeWidth");
				nRight = Math.max(pFromObj.x, pToObj.x, pArrow1.x, pArrow2.x)+getStyle("strokeWidth");
				nTop = Math.min(pFromObj.y, pToObj.y, pArrow1.y, pArrow2.y)-getStyle("strokeWidth");
				nBottom = Math.max(pFromObj.y, pToObj.y, pArrow1.y, pArrow2.y)+getStyle("strokeWidth");
				
				nWidth = Math.abs(nRight - nLeft);
				nHeight = Math.abs(nBottom - nTop);
				
				arrPolygon.push(pFromObj, pToObj, pArrow1, pArrow2)
				
				for each (var point:Point in arrPolygon)
				{
					point.offset(-nLeft, -nTop);
				}
			}	
			else
			{
				nLeft = parent.mouseX;
				nRight = parent.mouseX;
				nTop = parent.mouseY;
				nBottom = parent.mouseY;
				
				nWidth = 0;
				nHeight = 0;
			}		
		}
		
		private function drawArrows():void
		{			
			graphics.clear();				
			
			if(!arrPolygon || arrPolygon.length!=4)
				return;
				
			var focusColor:Number;
								
			if(bHighlighted)		{ focusColor=getStyle("focusHighlightColor"); }
			else if(bOver)			{ focusColor=getStyle("focusRollOverColor"); }
			else if(focused)		{ focusColor=getStyle("focusSelectionColor"); }
				
			graphics.lineStyle(SELECT_AREA_SIZE, 0x000000, 0.0);
			graphics.moveTo( arrPolygon[0].x, arrPolygon[0].y );
			graphics.lineTo( arrPolygon[1].x, arrPolygon[1].y );
											
			if((bOver || bHighlighted || bFocused) && bEnabled && toObj)
			{
				// Draw over focus
				graphics.lineStyle(getStyle("strokeWidth") + getStyle("focusThickness")*2, focusColor, getStyle("focusAlpha"));
				graphics.moveTo( arrPolygon[0].x, arrPolygon[0].y );
				graphics.lineTo( arrPolygon[1].x, arrPolygon[1].y );					
				graphics.lineTo( arrPolygon[2].x, arrPolygon[2].y );
				graphics.lineTo( arrPolygon[3].x, arrPolygon[3].y );
				graphics.lineTo( arrPolygon[1].x, arrPolygon[1].y );									
			}
			
			// Draw arrow
			
			var color:Number = getStyle("color");
			
			if(toObj)
			{
				if(!bEnabled)			{ color=getStyle("disabledColor"); }
				else if(bHighlighted)	{ color=getStyle("highlightColor"); }
				else if(bOver)			{ color=getStyle("rollOverColor"); }
				else if(focused)		{ color=getStyle("selectionColor"); }
			}
							
			graphics.lineStyle(getStyle("strokeWidth"), color, getStyle("alpha"), false, "normal", "round", JointStyle.MITER);	

			graphics.moveTo( arrPolygon[0].x, arrPolygon[0].y );
			graphics.beginFill(color, getStyle("alpha"));
			graphics.lineTo( arrPolygon[1].x, arrPolygon[1].y );					
			graphics.lineTo( arrPolygon[2].x, arrPolygon[2].y );
			graphics.lineTo( arrPolygon[3].x, arrPolygon[3].y );
			graphics.lineTo( arrPolygon[1].x, arrPolygon[1].y );	
			graphics.endFill();   					   				
		}			
	    
	    public function callRedraw():void
	    {
	    	bChanged = true;
	    	invalidateProperties();
	    }	
	    
	    public function beginEdit(point:Point = null):void
	    {	
	    	if(!(fromObject is GraphNode))
	    		return;
	    	
	    	if(!GraphNode(fromObject).arrTrans || GraphNode(fromObject).arrTrans.length==0)
	    		return;

			var cbChoise:ComboBox = new ComboBox();
			cbChoise.dataProvider = GraphNode(fromObject).arrTrans;
			cbChoise.addEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
			cbChoise.addEventListener(FlexEvent.CREATION_COMPLETE, comboBoxCreatedHandler);
				
			Application.application.setStyle("modalTransparencyBlur", 0);
			Application.application.setStyle("modalTransparency", 0);
			
			PopUpManager.addPopUp(cbChoise, parent, true);
			
			if(data)
			{
				for(var i:int=0; i<GraphNode(fromObject).arrTrans.length; i++)
				{
					if(GraphNode(fromObject).arrTrans[i]==data)
					{ 
						cbChoise.selectedIndex = i; 
						break;
					}
				}
			}
			
			var point:Point = point ? point : localToGlobal(new Point(mouseX, mouseY));
			cbChoise.move(point.x, point.y);			
	    }	    
	    
	    /**
	     *  Called when the user starts dragging an arrow
	     */
	    private function startDragging():void
	    {	        
	        systemManager.addEventListener(
	            MouseEvent.MOUSE_MOVE, graphArrow_systemManager_mouseMoveHandler, true);
	
	        systemManager.addEventListener(
	            MouseEvent.MOUSE_DOWN, graphArrow_systemManager_mouseDownHandler);
	    }
	
	    /**
	     *  Called when the user stops dragging an arrow
	     */
	    private function stopDragging():void
	    {
	        systemManager.removeEventListener(
	            MouseEvent.MOUSE_MOVE, graphArrow_systemManager_mouseMoveHandler, true);
	
	        systemManager.removeEventListener(
	            MouseEvent.MOUSE_DOWN, graphArrow_systemManager_mouseDownHandler);
	    }
	    	    
		//--------------------------------------------------------------------------
	    //
	    //  Event handlers
	    //
	    //--------------------------------------------------------------------------
	    
	    private function addHandler(event:FlexEvent):void
	    {	    
			focusManager = Container(parent).focusManager;           	
	    	
	    	systemManager.addEventListener(KeyboardEvent.KEY_DOWN, systemManager_keyDown);
	    }
	               	
	    private function mouseOverHandler(event:MouseEvent):void
	    {
	    	bOver = true;
	    	bChanged = true;
	    	
	    	PowerPackClass.refreshMenu(this);
	    	
			contextMenuOld = Application.application.contextMenu;
			if(contextMenu)
				Application.application.contextMenu = contextMenu;	
			    	
	    	event.stopPropagation();
			invalidateProperties();	
	    }	
	    private function mouseOutHandler(event:MouseEvent):void
	    {	
	    	bOver = false;
	    	bChanged = true;
	    	
	    	if(contextMenuOld)
	    		Application.application.contextMenu = contextMenuOld;
	    		
	    	invalidateProperties();	
	    }    
	    private function beginEditHandler(event:Object = null):void
	    {	
	    	beginEdit();			
	    }	
	    private function comboBoxCreatedHandler(event:FlexEvent):void
	    {			
			ComboBox(event.target).setFocus();
			ComboBox(event.target).open();
	    }	    
	    private function dropDownCloseHandler(event:DropdownEvent):void
	    {
	    	data = ComboBox(event.target).selectedItem;
	    	label = data.toString();
	    		    	
	    	ComboBox(event.target).removeEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
	    	ComboBox(event.target).removeEventListener(FlexEvent.CREATION_COMPLETE, comboBoxCreatedHandler);
	    	PopUpManager.removePopUp(ComboBox(event.target));
			Application.application.setStyle("modalTransparencyBlur", 3);
			Application.application.setStyle("modalTransparency", 0.5);	  
			setFocus();  	
	    }	
	        
		private function selectTransHandler(Event:ContextMenuEvent):void
		{
			beginEdit((parent as Container).contentToGlobal(new Point(x+width/2, y+height/2)));
		}		
		private function deleteArrowHandler(Event:ContextMenuEvent):void
		{
			alertDestroy();
		}
		private function enableHandler(Event:ContextMenuEvent):void
		{
			if(bEnabled)
				enabled = false;
			else
				enabled = true;				
		}
		private function highlightHandler(Event:ContextMenuEvent):void
		{
			if(bHighlighted)
				highlight = false;
			else
				highlight = true;				
		}	
	    private function alertRemoveHandler(event:CloseEvent):void 
	    {
        	if(event.detail==Alert.YES)
        	{        		
       			destroy();
   	     	}
		}	
	    private function graphArrow_systemManager_mouseMoveHandler(event:MouseEvent):void
	    {
	    	bChanged = true;
    	
	    	event.stopImmediatePropagation();
	    	invalidateProperties();	
	    }		
	    private function graphArrow_systemManager_mouseDownHandler(event:MouseEvent):void
	    {
	    	if(!toObj)
	    		destroy();
	    }	
		private function systemManager_keyDown(event:KeyboardEvent):void
	    {	    	
	    	if(!fromObj)
	    		return;
	    	// delete
			if(event.charCode == 127 && event.target==this)
	     	{
	     		alertDestroy();
		    }
		    // escape
		    else if(event.charCode == 27 && !toObj)
		    {
		    	destroy();
		    }		 
		    else if(event.charCode == 13 && event.target==this)
		    {		    	
		    	beginEdit((parent as Container).contentToGlobal(new Point(x+width/2, y+height/2)));
		    }
		}		
		private function graphArrow_focusInHandler(event:FocusEvent):void
		{
			//systemManager.stage.focus = this;
			invalidateDisplayList();		
		}			
		private function graphArrow_focusOutHandler(event:FocusEvent):void
		{
			invalidateDisplayList();		
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
			PowerPackClass.addMenuItemsByType("GraphArrow");
	       	
	       	mdm.Menu.Context[PowerPackClass.getMenuItemEventName("Delete Arrow")] = function():void{
				mdm.Dialogs.prompt(PowerPackClass.curObject);				
			};
	       	mdm.Menu.Context[PowerPackClass.getMenuItemEventName("Enable Arrow")] = function():void{
				mdm.Dialogs.prompt(PowerPackClass.curObject);				
			};
	       	mdm.Menu.Context[PowerPackClass.getMenuItemEventName("Highlight Arrow")] = function():void{
				mdm.Dialogs.prompt(PowerPackClass.curObject);	
			};
		}						      			    	    	      
	}
}