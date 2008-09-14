package PowerPack.com.graph
{
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.ui.SuperNativeMenu;
import ExtendedAPI.com.ui.SuperNativeMenuItem;

import GeomLib.GeomUtils;

import PowerPack.com.managers.ContextManager;
import PowerPack.com.managers.LanguageManager;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import mx.collections.ListCollectionView;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;
import mx.managers.PopUpManager;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;
import mx.utils.ArrayUtil;

//--------------------------------------
//  Events
//--------------------------------------	

[Event(name="enabledChanged", type="flash.events.ConnectorEvent")]
[Event(name="dataChanged", type="flash.events.ConnectorEvent")]	
[Event(name="labelChanged", type="flash.events.ConnectorEvent")]	
[Event(name="highlightedChanged", type="flash.events.ConnectorEvent")]
	
[Event(name="fromObjectChanged", type="flash.events.ConnectorEvent")]	
[Event(name="toObjectChanged", type="flash.events.ConnectorEvent")]	

[Event(name="disposed", type="flash.events.ConnectorEvent")]		

//--------------------------------------
//  Styles
//--------------------------------------

[Style(name="color", type="uint", format="Color", inherit="yes")]
[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
[Style(name="highlightColor", type="uint", format="Color", inherit="no")]
[Style(name="disabledColor", type="uint", format="Color", inherit="yes")]

[Style(name="alpha", type="Number", format="Length", inherit="yes")]	
[Style(name="strokeWidth", type="Number", format="Length", inherit="yes")]

[Style(name="arrowSize", type="Number", format="Length", inherit="no")]
[Style(name="arrowAngle", type="Number", format="Length", inherit="no")]

[Style(name="focusRollOverColor", type="uint", format="Color", inherit="no")]
[Style(name="focusSelectionColor", type="uint", format="Color", inherit="no")]
[Style(name="focusHighlightColor", type="uint", format="Color", inherit="no")]
[Style(name="focusAlpha", type="Number", format="Length", inherit="no")]
[Style(name="focusThickness", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

//[IconFile("Connector.png")]

public class Connector extends UIComponent implements IFocusManagerComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------		
    
    /**
    * Defines area offset around an connector where it can receive focus
    */
    
    public static const CM_CENTER:String = "toCenter";
    public static const CM_NEAREST:String = "toNearest";
    
    private static const SELECT_AREA_SIZE:int = 5;
    public static var connectMode:String = CM_CENTER;

    private static var modalTransparencyBlur:Number;
    private static var modalTransparency:Number;
    
    public static var connectors:Dictionary = new Dictionary(); 
    
    private static var defaultCaptions:Object = {
    	connector_select_trans: "Edit transition",
    	connector_delete:"Delete transition", 
    	connector_enable:"Enable transition", 
    	connector_highlight:"Highlight transition",
    	connector_alert_delete_title: "Confirmation",
    	connector_alert_delete_text: "Are you sure want to delete this transition?"
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
        if (!StyleManager.getStyleDeclaration("Connector"))
        {
            // If there is no CSS definition for Connector, 
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
            newStyleDeclaration.setStyle("arrowAngle", 50);
            
            newStyleDeclaration.setStyle("focusThickness", 2);
            newStyleDeclaration.setStyle("focusRollOverColor", newStyleDeclaration.getStyle("themeColor"));
            newStyleDeclaration.setStyle("focusSelectionColor", newStyleDeclaration.getStyle("themeColor"));
            newStyleDeclaration.setStyle("focusHighlightColor", newStyleDeclaration.getStyle("themeColor"));                
            newStyleDeclaration.setStyle("focusAlpha", 0.4);
            
            StyleManager.setStyleDeclaration("Connector", newStyleDeclaration, true);
        }

    	LanguageManager.setSentences(defaultCaptions);
    	
        return true;
    }        	  

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Constructor.
     */
	public function Connector()
	{
		super();
		
		doubleClickEnabled = true;
		focusEnabled = true;
		mouseFocusEnabled = true;
		tabEnabled = true;	
		tabChildren = false;
		styleName = this.className;	
		cacheAsBitmap = true;
		
		connectors[this] = this;
	}

	//--------------------------------------------------------------------------
	//
	//  Destructor
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Destructor.
     */
	public function dispose():void
	{			
		if(contextMenu)
		{	
        	contextMenu.removeEventListener(Event.SELECT, contextMenuSelectHandler);	        	 
			SuperNativeMenu(contextMenu).dispose();
  		}	
  				
  		stopDragging();
   		
       	Application.application.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);            
       	removeEventListener(KeyboardEvent.KEY_DOWN, onConnectorKeyDown);           

   		removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        removeEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);

        if(parent)
    	{
           	parent.removeChild(this);
        }
           	
       	dispatchEvent(new ConnectorEvent(ConnectorEvent.DISPOSED));
       	
       	delete connectors[this];
	}	

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
    private var _over:Boolean;
    private var _created:Boolean;
    public var canvas:GraphCanvas;

    [ArrayElementType("Point")]
    private var _connectorPoly:Array = []; 
    
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  focused
    //----------------------------------
    		
    private var _focused:Boolean = false;
    
    public function get focused():Boolean
    {
    	if(this.getFocus()==this)
    		_focused = true;
    	else 
    		_focused = false;
    	
        return _focused;
    }

    //----------------------------------
    //  highlight
    //----------------------------------
    
    private var _highlighted:Boolean = false;
	private var _highlightedChanged:Boolean = false;
	
    [Bindable("highlightedChanged")]
    [Inspectable(category="General", enumeration="true,false", defaultValue="false")]

    public function get highlighted():Boolean
    {
        return _highlighted;
    }	
    public function set highlighted(value:Boolean):void
    {
		if(_highlighted!=value)
		{
        	_highlighted = value;
        	_highlightedChanged = true;
        
        	invalidateProperties();
			invalidateDisplayList();
			         
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.HIGHLIGHTED_CHANGED));
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.GRAPH_CHANGED));
  		}
    }

    //----------------------------------
    //  enabled
    //----------------------------------
   	    
    private var _enabled:Boolean = true;
	private var _enabledChanged:Boolean = false;
	
    [Bindable("enabledChanged")]
    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]

    override public function get enabled():Boolean
    {
        return _enabled;
    }   
    override public function set enabled(value:Boolean):void
    {
    	if(_enabled != value)
    	{
    		super.enabled = value;
    	
        	_enabled = value;
        	_enabledChanged = true;
        
	        invalidateProperties();
			invalidateDisplayList();
			         
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.ENABLED_CHANGED));
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.GRAPH_CHANGED));
    	}
    }	

    //----------------------------------
    //  label
    //----------------------------------
    
    private var _label:String;
    private var _labelChanged:Boolean = false;	    
	
    [Bindable("labelChanged")]
    [Inspectable(category="General", defaultValue="Connector")]

    public function get label():String
    {
        return _label;
    }	     
    public function set label(value:String):void
    {
    	if(_label != value)
    	{
        	_label = value;
        	_labelChanged = true;
        
	        invalidateProperties();
         
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.LABEL_CHANGED));
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.GRAPH_CHANGED));
    	}
    }

    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object;
    private var _dataChanged:Boolean;

    [Bindable("dataChanged")]
    [Inspectable(category="General")]

    public function get data():Object
    {
        return _data;
    }
    public function set data(value:Object):void
    {
    	if(_data != value)
    	{
        	_data = value;	   
        	_dataChanged = true;
        	
        	invalidateProperties();
        	      
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.DATA_CHANGED));
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.GRAPH_CHANGED));
     	}
    }

    //----------------------------------
    //  fromObject
    //----------------------------------
    
	private var _fromObj:UIComponent = null;
    private var _fromObjChanged:Boolean;	    
	
    [Bindable("fromObjectChanged")]
    [Inspectable(category="General")]

    public function get fromObject():UIComponent
    {
        return _fromObj;
    }
    public function set fromObject(value:UIComponent):void
    {
    	if(_fromObj != value)
    	{
			if(_fromObj)
				_fromObj.removeEventListener(FlexEvent.UPDATE_COMPLETE, onObjectUpdated);    		
        	
        	_fromObj = value;
        	_fromObjChanged = true;
        	
        	if(_fromObj)
        		_fromObj.addEventListener(FlexEvent.UPDATE_COMPLETE, onObjectUpdated);
        
	        invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			         
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.FROM_OBJECT_CHANGED));
     	}
    }

    //----------------------------------
    //  toObject
    //----------------------------------
    		
	private var _toObj:UIComponent = null;	
    private var _toObjChanged:Boolean = false;	    
	
    [Bindable("toObjectChanged")]
    [Inspectable(category="General")]

    public function get toObject():UIComponent
    {
        return _toObj;
    }	
    public function set toObject(value:UIComponent):void
    {
    	if(_toObj != value)
    	{
			if(_toObj)
				_toObj.removeEventListener(FlexEvent.UPDATE_COMPLETE, onObjectUpdated);    		

        	_toObj = value;
    	    _toObjChanged = true;
        
			if(_toObj)
				_toObj.addEventListener(FlexEvent.UPDATE_COMPLETE, onObjectUpdated);    		

	        invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			         
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.TO_OBJECT_CHANGED));
     	}
    }	
		
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------	
	
    override public function styleChanged(styleProp:String):void 
    {
        super.styleChanged(styleProp);
    	
    	if (styleProp=="strokeWidth" || 
    		styleProp=="arrowAngle" || 
    		styleProp=="arrowSize" || 
    		styleProp=="lineEndIcon") 
    	{
        	invalidateSize();
    	}
    	
        invalidateDisplayList();
	}
	
	/**
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        super.createChildren();

        if(focusManager)
        {
        	focusManager.showFocusIndicator = false;
        }
        
        if (ContextManager.FLASH_CONTEXT_MENU && !contextMenu)
        {
        	contextMenu = new SuperNativeMenu();
        	
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['connector_select_trans'], 'select_trans', false, null, false, false));
        	contextMenu.addItem(new SuperNativeMenuItem('normal', LanguageManager.sentences['connector_delete'], 'delete', false, null, false, false));
        	contextMenu.addItem(new SuperNativeMenuItem('separator'));
        	contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['connector_enable'], 'enable', _enabled, null, false, false));
        	contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['connector_highlight'], 'highlight', _highlighted, null, false, false));
        	
	       	for each (var item:NativeMenuItem in contextMenu.items) {
	       		//LanguageManager.bindSentence('connector_'+item.name, item);
	       	}
			        	
        	contextMenu.addEventListener(Event.SELECT, contextMenuSelectHandler);	        	 
        }
        
        if(!_created) {
        	_created = true;  
        	
        	canvas = parent as GraphCanvas;      	
        	Application.application.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);            
        	addEventListener(KeyboardEvent.KEY_DOWN, onConnectorKeyDown);            
        }
    }

    override protected function commitProperties():void
    {
        super.commitProperties();
        	        
        if (_enabledChanged)
        {
            _enabledChanged = false;
            invalidateDisplayList();
        }
        if (_highlightedChanged)
        {
            _highlightedChanged = false;
            invalidateDisplayList();
        }
        
        if (_dataChanged)
        {
            _dataChanged = false;
            
            if(!data)
            {
            	_label = null;
            }
            if(data is Array)
            {
            	if((data as Array).length==0)
            		_label = null;            	
            	else if(ArrayUtil.getItemIndex(label, data as Array)==-1)
            		_label = data[0];            	                       
            }
            else if(data is ListCollectionView)
            {
            	if((data as ListCollectionView).length==0)
            		_label = null;            	
            	if(ListCollectionView(data).getItemIndex(label)==-1)
            		_label = data[0];
            }
            else
            {
            	_label = data.toString();
            }
            
          	toolTip = label;

			invalidateDisplayList();
        }
        
        if (_labelChanged)
        {
            _labelChanged = false;
            toolTip = label;

        	invalidateDisplayList();
        }

        if(_fromObjChanged || _toObjChanged)
        {
			_fromObjChanged = false;
			_toObjChanged = false;

			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	    	removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	    	removeEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
	    
	        if(contextMenu)
	        {
	        	for each (var menuItem:NativeMenuItem in contextMenu.items)
	            	menuItem.enabled = false;
	        }	
	        
	        if(_fromObj && _toObj)
	        {
	    		addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	            addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	            addEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
	        
	            if(contextMenu)
	            {
	            	for each (menuItem in contextMenu.items)
		            	menuItem.enabled = true;
	            }
	        }
        
			stopDragging();
			
			if((_fromObj || _toObj) && (!_fromObj || !_toObj) && parent)
			{
				startDragging();
			}

			invalidateSize();
			invalidateDisplayList();			
        }
    }
    
	override protected function measure():void 
	{
        super.measure();
        
        measuredMinWidth = measuredWidth = 0;                
        measuredMinHeight = measuredHeight = 0;                
         
		calcSize(connectMode);
		
   		invalidateDisplayList();
    }  	    		
   
	// Override updateDisplayList() to update the component 
	override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);	
        
		drawArrows();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	public function clone():Connector
	{
		var newConnector:Connector = new Connector();
		newConnector.enabled = enabled;
		newConnector.highlighted = highlighted;
		newConnector.label = label;
		//newConnector.data = ObjectUtils.baseClone(data);
		return newConnector; 
	}
	
	public function alertDestroy():void
	{			
 		if(parent)
 		{
     		SuperAlert.show(
     			LanguageManager.sentences['connector_alert_delete_text'], 
     			LanguageManager.sentences['connector_alert_delete_title'], 
     			Alert.YES|Alert.NO, null, alertRemoveHandler, null, Alert.YES);			     	
     	}
	}	
			
	private function calcSize(mode:String='toCenter'):void
	{
		_connectorPoly = [];
		
		if(!fromObject && !toObject)
			return;
		
		var fromP:Point = new Point(
	   		Container(parent).contentMouseX,
	   		Container(parent).contentMouseY );
	   		
		var toP:Point = fromP.clone();
		
		var fromRect:Rectangle =  new Rectangle();		
		fromRect.topLeft = fromP;		
		fromRect.bottomRight = fromP;
			   		
		var toRect:Rectangle =  fromRect.clone();
		
		if(fromObject)
		{
			var p1:Point = new Point(				
				fromObject.x,
				fromObject.y);
			
			fromRect = new Rectangle(
				p1.x,
				p1.y,
				fromObject.width,
				fromObject.height );
				
			//fromRect.inflate(1, 1);
			
			fromP = Point.interpolate(fromRect.topLeft, fromRect.bottomRight, 0.5);
   		}
   		   			
   		if(toObject)
   		{
			var p2:Point = new Point(				
				toObject.x,
				toObject.y);

			toRect = new Rectangle(
				p2.x,
				p2.y,
				toObject.width,
				toObject.height);

			toRect.inflate(1, 1);
   			
			toP = Point.interpolate(toRect.topLeft, toRect.bottomRight, 0.5);
   		}

   		fromRect.width += fromRect.width>0?0:1;
   		fromRect.height += fromRect.height>0?0:1;
   		toRect.width += toRect.width>0?0:1;
   		toRect.height += toRect.height>0?0:1;
   		
   		if(fromRect.intersects(toRect))
   			return;
   		
   		var rect:Rectangle = new Rectangle();
   		var intersect:Rectangle;
   		var union:Rectangle;

   		if(mode == CM_CENTER)
   		{
	   		rect.left = Math.min(fromP.x, toP.x);
	   		rect.top = Math.min(fromP.y, toP.y);
	   		rect.right = Math.max(fromP.x, toP.x);
	   		rect.bottom = Math.max(fromP.y, toP.y);
	   		
	   		rect.width += rect.width>0?0:1;
	   		rect.height += rect.height>0?0:1;
	   		
	   		var coef:Number = rect.width/rect.height;
	   		var coef1:Number = fromRect.width/fromRect.height;
	   		var coef2:Number = toRect.width/toRect.height;
	   		
	   		intersect = fromRect.intersection(rect);
	   		fromP.x += (intersect.left==fromP.x?1:-1)*intersect.width * (coef>coef1?1:coef/coef1);	
	   		fromP.y += (intersect.top==fromP.y?1:-1)*intersect.height * (coef>coef1?coef1/coef:1);	
	   		
	   		intersect = toRect.intersection(rect);
	   		toP.x += (intersect.left==toP.x?1:-1)*intersect.width * (coef>coef2?1:coef/coef2);	
	   		toP.y += (intersect.top==toP.y?1:-1)*intersect.height * (coef>coef2?coef2/coef:1);
	   	}
	   	else
	   	{
	   		var delta:int = 1;
	   		union = GeomUtils.diffRect(fromRect, toRect);
	   		
	   		if(fromRect.right-delta<toRect.left+delta) {
	   			fromP.x = fromRect.right-delta; 
	   			toP.x = toRect.left+delta;
	   		}
	   		else if(toRect.right-delta<fromRect.left+delta) {
	   			fromP.x = fromRect.left+delta; 
	   			toP.x = toRect.right-delta;
	   		}
	   		else {
	   			fromP.x = toP.x = union.x + union.width/2;
	   		}

	   		if(fromRect.bottom-delta<toRect.top+delta) {
	   			fromP.y = fromRect.bottom-delta; 
	   			toP.y = toRect.top+delta;
	   		}
	   		else if(toRect.bottom-delta<fromRect.top+delta) {
	   			fromP.y = fromRect.top+delta; 
	   			toP.y = toRect.bottom-delta;
	   		}
	   		else {
	   			fromP.y = toP.y = union.y + union.height/2;
	   		}
	   	}		
   			
		/**
		 * Arrow pointer
		 */ 
								
		var angle:Number = Math.atan2( fromP.y-toP.y, fromP.x-toP.x );				
		var dAngle:Number = (getStyle("arrowAngle")/2) * Math.PI/180;				
		var dLen:Number = getStyle("arrowSize");

		var pArrow1:Point = Point.polar( dLen, angle+dAngle );
		pArrow1.offset( toP.x, toP.y );
		var pArrow2:Point = Point.polar( dLen, angle-dAngle );	
		pArrow2.offset( toP.x, toP.y );				
			
		/**
		 *  Fill in polygon array
		 */				
			
   		rect.left = Math.min(fromP.x, toP.x, pArrow1.x, pArrow2.x);
   		rect.top = Math.min(fromP.y, toP.y, pArrow1.y, pArrow2.y);
   		rect.right = Math.max(fromP.x, toP.x, pArrow1.x, pArrow2.x);
   		rect.bottom = Math.max(fromP.y, toP.y, pArrow1.y, pArrow2.y);
   		
		_connectorPoly.push(fromP, toP, pArrow1, pArrow2)
			
		for each (var point:Point in _connectorPoly) {
			point.offset(-rect.x, -rect.y);
		}

		measuredWidth = rect.width;
		measuredHeight = rect.height;
		
		move(rect.x, rect.y);
	}
	
	private function drawArrows():void
	{			
		graphics.clear();				
		
		if(!_connectorPoly || _connectorPoly.length<2)
			return;
			
		var focusColor:Number = -1;
							
		if(_highlighted)		{ focusColor=getStyle("focusHighlightColor"); }
		else if(_over)			{ focusColor=getStyle("focusRollOverColor"); }
		else if(focused)		{ focusColor=getStyle("focusSelectionColor"); }
			
		var color:Number = getStyle("color");
		
		if(!_enabled)			{ color=getStyle("disabledColor"); }
		else if(_highlighted)	{ color=getStyle("highlightColor"); }
		else if(_over)			{ color=getStyle("rollOverColor"); }
		else if(focused)		{ color=getStyle("selectionColor"); }

		// Define intercative area
		graphics.lineStyle(SELECT_AREA_SIZE, 0x000000, 0.0);
		graphics.moveTo( _connectorPoly[0].x, _connectorPoly[0].y );
		graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );
										
		if(focusColor>=0 && _enabled)
		{
			// Draw outline
			graphics.lineStyle(getStyle("strokeWidth") + getStyle("focusThickness")*2, 
				focusColor, getStyle("focusAlpha"));
				
			graphics.moveTo( _connectorPoly[0].x, _connectorPoly[0].y );
			graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );			
								
			graphics.lineTo( _connectorPoly[2].x, _connectorPoly[2].y );
			graphics.lineTo( _connectorPoly[3].x, _connectorPoly[3].y );
			graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );									
		}
		
		// Draw arrow		
						
		graphics.lineStyle(getStyle("strokeWidth"), color, getStyle("alpha"), false, "normal", CapsStyle.NONE, JointStyle.MITER);	
					
		graphics.moveTo( _connectorPoly[0].x, _connectorPoly[0].y );
		graphics.beginFill(color, getStyle("alpha"));
		graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );					
		graphics.lineTo( _connectorPoly[2].x, _connectorPoly[2].y );
		graphics.lineTo( _connectorPoly[3].x, _connectorPoly[3].y );
		graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );	
		graphics.endFill();  
		
		//graphics.drawRect(0,0,getExplicitOrMeasuredWidth(),getExplicitOrMeasuredHeight());
	}			
    
    public function beginEdit(atCursorPosition:Boolean = true, position:Point = null):void
    {	
    	if(!fromObject || !toObject)
    		return;
    	
    	if(	!data ||
    		data is Array && (data as Array).length==0 ||
    		data is ListCollectionView && (data as ListCollectionView).length==0)    		
    		return;
    	
		var cbChoise:ComboBox = new ComboBox();
		cbChoise.dataProvider = data;
		cbChoise.addEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
		cbChoise.addEventListener(FlexEvent.CREATION_COMPLETE, comboBoxCreatedHandler);
		
		modalTransparencyBlur = Application.application.getStyle("modalTransparencyBlur");
		modalTransparency = Application.application.getStyle("modalTransparency");
					
		Application.application.setStyle("modalTransparencyBlur", 0);
		Application.application.setStyle("modalTransparency", 0);
		
		PopUpManager.addPopUp(cbChoise, parent, true);
		
		if(label)
			cbChoise.selectedItem = label;
		
		var point:Point = atCursorPosition ? localToGlobal(new Point(mouseX, mouseY)) : 
			Container(parent).contentToGlobal(new Point(x+width/2, y+height/2));
		
		if(position)
			point = position;
			
		cbChoise.move(point.x, point.y);			
    }	    
    
    /**
     *  Called when the user starts dragging an connector
     */
    private function startDragging():void
    {	        
        systemManager.addEventListener(
            MouseEvent.MOUSE_MOVE, connector_systemManager_mouseMoveHandler, true);

        systemManager.addEventListener(
            MouseEvent.MOUSE_DOWN, connector_systemManager_mouseDownHandler);
    }

    /**
     *  Called when the user stops dragging an connector
     */
    private function stopDragging():void
    {
        systemManager.removeEventListener(
            MouseEvent.MOUSE_MOVE, connector_systemManager_mouseMoveHandler, true);

        systemManager.removeEventListener(
            MouseEvent.MOUSE_DOWN, connector_systemManager_mouseDownHandler);
    }
    	    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function mouseOverHandler(event:MouseEvent):void
    {
    	event.stopPropagation();

    	_over = true;    	
		invalidateDisplayList();	
    }	
    
    private function mouseOutHandler(event:MouseEvent):void
    {	
    	_over = false;
		invalidateDisplayList();	
    }
    
    private function onObjectUpdated(event:Event):void
    {
    	invalidateSize();    	
    }
        
    private function beginEditHandler(event:Event):void
    {	
    	event.stopPropagation();
    	beginEdit();			
    }	

    private function comboBoxCreatedHandler(event:FlexEvent):void
    {			
		ComboBox(event.target).setFocus();
		ComboBox(event.target).open();
    }	    

    private function dropDownCloseHandler(event:DropdownEvent):void
    {
    	label = ComboBox(event.target).selectedLabel;
    		    	
    	ComboBox(event.target).removeEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
    	ComboBox(event.target).removeEventListener(FlexEvent.CREATION_COMPLETE, comboBoxCreatedHandler);
    	PopUpManager.removePopUp(ComboBox(event.target));
    	
		Application.application.setStyle("modalTransparencyBlur", modalTransparencyBlur);
		Application.application.setStyle("modalTransparency", modalTransparency);	  
		setFocus();  	
    }	
        
	private function contextMenuSelectHandler(event:Event):void
	{
		switch(event.target.name)
		{
			case "select_trans":
				beginEdit(false);
				break;
			case "delete":
				alertDestroy();
				break;
			case "enable":
				enabled = !enabled;
				break;
			case "highlight":
				highlighted = !highlighted;
				break;
		}
	}	

    private function alertRemoveHandler(event:CloseEvent):void 
    {
    	if(event.detail==Alert.YES) {        		
   			dispose();
        }
	}	

    private function connector_systemManager_mouseMoveHandler(event:MouseEvent):void
    {
    	event.stopImmediatePropagation();
    	invalidateSize();
    }		

    private function connector_systemManager_mouseDownHandler(event:MouseEvent):void
    {
    	if(!fromObject || !toObject) {
    		fromObject = null;
    		toObject = null;
    	}
    	
    	invalidateProperties();
    }	

	private function onKeyDown(event:KeyboardEvent):void
    {
	    if(	event.keyCode == Keyboard.ESCAPE && 
	    	(!toObject || !fromObject))
	    {
	    	fromObject = null;
	    	toObject = null;
	    }		 
	}
	
	private function onConnectorKeyDown(event:KeyboardEvent):void
    {
    	event.stopPropagation();
    	
		if(event.keyCode == Keyboard.DELETE)
     	{
     		alertDestroy();
	    }
	    else if(event.keyCode == Keyboard.ENTER)
	    {		    	
	    	beginEdit(false);
	    }
	}
	
    /**
     *  @private
     */
    override protected function focusOutHandler(event:FocusEvent):void
    {
    	_focused = false;

        super.focusOutHandler(event);

        invalidateDisplayList();
    }

    override protected function focusInHandler(event:FocusEvent):void
    {
    	_focused = true;
    	
        super.focusInHandler(event);

        invalidateDisplayList();
    }    	
}
}