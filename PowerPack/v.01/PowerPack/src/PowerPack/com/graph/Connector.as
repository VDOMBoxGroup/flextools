package PowerPack.com.graph
{
import ExtendedAPI.com.containers.SuperAlert;
import ExtendedAPI.com.ui.SuperNativeMenu;
import ExtendedAPI.com.ui.SuperNativeMenuItem;
import ExtendedAPI.com.utils.ObjectUtils;
import ExtendedAPI.com.utils.Utils;

import GeomLib.GeomUtils;
import GeomLib._2D.LineSegment;

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

import mx.binding.utils.BindingUtils;
import mx.binding.utils.ChangeWatcher;
import mx.collections.ListCollectionView;
import mx.controls.Alert;
import mx.controls.ComboBox;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
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
    public static const CM_MIX:String = "mix";
    
    public static var connectMode:String = CM_CENTER;
    public static var deleteConfirmation:Boolean = true;
    
    public static var connectors:Dictionary = new Dictionary(); 
    
    private static const SELECT_AREA_SIZE:int = 5;

    private static var modalTransparencyBlur:Number;
    private static var modalTransparency:Number;
    
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
            newStyleDeclaration.setStyle("arrowSize", 7);
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
  				
        systemManager.removeEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        systemManager.removeEventListener(
            MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
   		
       	systemManager.removeEventListener(
       		KeyboardEvent.KEY_DOWN, systemManager_keyDownHandler);            

       	removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);           
   		removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
   		removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        removeEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
        removeEventListener(MouseEvent.CONTEXT_MENU, contextHandler);
		
		if(_dataWatcher)
			_dataWatcher.unwatch();
		
		if(_fromObject)
		{
			_fromObject.removeEventListener(FlexEvent.UPDATE_COMPLETE, objectUpdateHandler);    		
			_fromObject.removeEventListener(MoveEvent.MOVE , objectUpdateHandler);    	
			
			if(fromObject is Node)
			{		
				var i:int = (fromObject as Node).outArrows.getItemIndex(this);
				if(i>=0)
					(fromObject as Node).outArrows.removeItemAt(i);
			}
		}
						
		if(_toObject)
		{
			_toObject.removeEventListener(FlexEvent.UPDATE_COMPLETE, objectUpdateHandler);    		
			_toObject.removeEventListener(MoveEvent.MOVE , objectUpdateHandler);    	
    	
			if(toObject is Node)
			{		
				i = (toObject as Node).inArrows.getItemIndex(this);
				if(i>=0)
  					(toObject as Node).inArrows.removeItemAt(i);
			}
		}
		  			
        if(parent)
           	parent.removeChild(this);
           	
       	delete connectors[this];

       	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
       	dispatchEvent(new ConnectorEvent(ConnectorEvent.DISPOSED));
	}	

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
    private var _over:Boolean;
    private var _created:Boolean;
    private var _dataWatcher:ChangeWatcher;

    [ArrayElementType("Point")]
    private var _connectorPoly:Array = []; 
    
    public var canvas:GraphCanvas;

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	
    //----------------------------------
    //  fromPoint
    //----------------------------------
    		
    public function get fromPoint():Point
    {
    	if(_connectorPoly && _connectorPoly.length>0)
        	return Point(_connectorPoly[0]).clone();
        	
        return null;
        
    }

    //----------------------------------
    //  toPoint
    //----------------------------------
    		
    public function get toPoint():Point
    {
    	if(_connectorPoly && _connectorPoly.length>1)
        	return Point(_connectorPoly[1]).clone();
        	
        return null;
        
    }

    //----------------------------------
    //  focused
    //----------------------------------
    		
    private var _focused:Boolean;
    
    public function get focused():Boolean
    {
    	if(focusManager.getFocus()==this)
    		_focused = true;
    	else 
    		_focused = false;
    	
        return _focused;
    }

    //----------------------------------
    //  interactive
    //----------------------------------
    		
    private var _interactive:Boolean;
    private var _interactiveChange:Boolean;
    
    public function set interactive(value:Boolean):void
    {
    	if(_interactive!=value)
    	{
    		_interactive = value;    			
    		_interactiveChange = true;
    		
    		invalidateProperties();	
    		dispatchEvent(new ConnectorEvent(ConnectorEvent.INTERACTIVE_CHANGED));
    	}
    }
    public function get interactive():Boolean
    {
        return _interactive;
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
    	    //dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
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
    	    dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
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
    	    dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
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
        	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
     	}
    }

    //----------------------------------
    //  fromObject
    //----------------------------------
    
	private var _fromObject:UIComponent = null;
    private var _fromObjectChanged:Boolean;	    
	
    [Bindable("fromObjectChanged")]
    [Inspectable(category="General")]

    public function get fromObject():UIComponent
    {
        return _fromObject;
    }
    public function set fromObject(value:UIComponent):void
    {
    	if(_fromObject != value)
    	{
			if(_fromObject) {
				_fromObject.removeEventListener(FlexEvent.UPDATE_COMPLETE, objectUpdateHandler);    		
				_fromObject.removeEventListener(MoveEvent.MOVE , objectUpdateHandler);    		
			}
        	
        	_fromObject = value;
        	_fromObjectChanged = true;
        	
        	if(_fromObject) {
        		_fromObject.addEventListener(FlexEvent.UPDATE_COMPLETE, objectUpdateHandler);
        		_fromObject.addEventListener(MoveEvent.MOVE , objectUpdateHandler);    	
        	}
        	
	        invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			         
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.FROM_OBJECT_CHANGED));
        	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
     	}
    }

    //----------------------------------
    //  toObject
    //----------------------------------
    		
	private var _toObject:UIComponent = null;	
    private var _toObjectChanged:Boolean = false;	    
	
    [Bindable("toObjectChanged")]
    [Inspectable(category="General")]

    public function get toObject():UIComponent
    {
        return _toObject;
    }	
    public function set toObject(value:UIComponent):void
    {
    	if(_toObject != value)
    	{
			if(_toObject) {
				_toObject.removeEventListener(FlexEvent.UPDATE_COMPLETE, objectUpdateHandler);    		
				_toObject.removeEventListener(MoveEvent.MOVE , objectUpdateHandler); 				
			}

        	_toObject = value;
    	    _toObjectChanged = true;
        
			if(_toObject) {
				_toObject.addEventListener(FlexEvent.UPDATE_COMPLETE, objectUpdateHandler);
				_toObject.addEventListener(MoveEvent.MOVE , objectUpdateHandler);     		
			}
			
	        invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			         
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.TO_OBJECT_CHANGED));
        	dispatchEvent(new GraphCanvasEvent(GraphCanvasEvent.GRAPH_CHANGED));
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
        	//contextMenu.addItem(new SuperNativeMenuItem('check', LanguageManager.sentences['connector_highlight'], 'highlight', _highlighted, null, false, false));
			        	
        	contextMenu.addEventListener(Event.SELECT, contextMenuSelectHandler);	        	 
        }
        
        if(!_created) {
        	_created = true;	
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
        
        if (_labelChanged)
        {
            _labelChanged = false;
            toolTip = label;

        	invalidateDisplayList();
        }

        if(_fromObjectChanged || _toObjectChanged)
        {
			_fromObjectChanged = false;
			_toObjectChanged = false;
	        
	        if(!_interactiveChange) {
				_interactiveChange = true;
				_interactive = false;	        	
	        }	        
        	
        	systemManager.removeEventListener(KeyboardEvent.KEY_DOWN, systemManager_keyDownHandler);
			stopDragging();
			
			if((_fromObject && !_toObject || !_fromObject && _toObject) && parent)
			{
				_over = false;
				systemManager.addEventListener(KeyboardEvent.KEY_DOWN, systemManager_keyDownHandler);  
				startDragging();
			}

			invalidateSize();
			invalidateDisplayList();			
        }
        
        if(_interactiveChange)
        {
        	_interactiveChange = false;
				
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	    	removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	    	removeEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
	    	removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	    	removeEventListener(MouseEvent.CONTEXT_MENU, contextHandler);
	    
	        if(contextMenu)
	        {
	        	for each (var menuItem:NativeMenuItem in contextMenu.items)
	            	menuItem.enabled = false;
	        }
	        
	        unbindNodes();	
		        
        	if(!_fromObject || !_toObject)
        		_interactive = false;
        	
        	if(_interactive)
        	{
	        	addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	    		addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
	            addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
	            addEventListener(MouseEvent.DOUBLE_CLICK, beginEditHandler);
	    		addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	    		addEventListener(MouseEvent.CONTEXT_MENU, contextHandler);
	    		    
	            if(contextMenu)
	            {
	            	for each (menuItem in contextMenu.items)
		            	menuItem.enabled = true;
	            }
	            
	            bindNodes();
        	}
        }
        if (_dataChanged)
        {
            _dataChanged = false;
            
            if(data == null)
            {
            	_label = null;
            }   
            else if(data is Array)
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
            else if(data is String)
            {
            	_label = data.toString();
            }
            else
            {
            	if(!data[_label])
            		_label = null;
            }
            
          	toolTip = label;

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
	
	private function bindNodes():void
	{
        if(_fromObject is Node)
        {
        	_dataWatcher = BindingUtils.bindProperty(this, 'data',
				_fromObject, 'arrTrans');
		
			(_fromObject as Node).outArrows.addItem(this);
        }
        if(_toObject is Node)
			(_toObject as Node).inArrows.addItem(this);		
	}
	
	private function unbindNodes():void
	{
		if(_dataWatcher)
			_dataWatcher.unwatch();
			
		if(_fromObject is Node)
		{		
			var i:int = (_fromObject as Node).outArrows.getItemIndex(this);
			if(i>=0)
				(_fromObject as Node).outArrows.removeItemAt(i);
		}
		
		if(_toObject is Node)
		{		
			i = (_toObject as Node).inArrows.getItemIndex(this);
			if(i>=0)
				(_toObject as Node).inArrows.removeItemAt(i);
		}
	}

	public function toXML():XML
	{
		var arrowXML:XML = new XML(<transition/>);
		arrowXML.@name = name;
		arrowXML.@highlighted = highlighted;
		arrowXML.@enabled = enabled;
		arrowXML.@source = fromObject.name;
		arrowXML.@destination = toObject.name;
		if(label)
			arrowXML.label = label;
			
		return arrowXML;
	}
		
	public function clone():Connector
	{
		var newConnector:Connector = new Connector();
		newConnector.enabled = enabled;
		newConnector.highlighted = highlighted;
		newConnector.label = label;
		newConnector.data = ObjectUtils.baseClone(data);		
		return newConnector; 
	}
	
	public function remove():void
	{			
 		if(parent)
 		{
 			if(deleteConfirmation)
	     		SuperAlert.show(
	     			LanguageManager.sentences['connector_alert_delete_text'], 
	     			LanguageManager.sentences['connector_alert_delete_title'], 
	     			Alert.YES|Alert.NO, null, alertRemoveHandler, null, Alert.YES);
	     	else
	     		dispose();			     	
     	}
	}	
	
	public function _getVisibleRect():Rectangle
	{
		if(!parent || !fromPoint || !toPoint)
			return null; 
			
		var visibleRect:Rectangle = getVisibleRect();//Utils.getVisibleRect(this);
		
		var lineSeg:LineSegment = new LineSegment(
			contentToGlobal(fromPoint),
			contentToGlobal(toPoint));

		var arr:Array = GeomUtils.rectLineIntersection(visibleRect, lineSeg);
		
		if(!arr || arr.length==0)
			return visibleRect;
		
		var lineVisibleRect:Rectangle = ExtendedAPI.com.utils.GeomUtils.getObjectsRect(arr);
		
		return lineVisibleRect;
	}
    
    public function beginEdit(atCursorPosition:Boolean = true, position:Point = null):void
    {	
    	if(!fromObject || !toObject || !parent)
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
		
		var visibleRect:Rectangle = _getVisibleRect();
		var point:Point; 
		
		if(atCursorPosition)
		{
			point = localToGlobal(new Point(mouseX, mouseY));
		}
		else if(position)
		{
			point = position;
		}
		else if(visibleRect && !visibleRect.isEmpty())
		{
			point = visibleRect.topLeft.clone();
			point.offset(	(visibleRect.width-cbChoise.width)/2, 
							(visibleRect.height-cbChoise.height)/2);
		}
		else
		{
			point = Container(parent).contentToGlobal(new Point(x+(width-cbChoise.width)/2, y+(height-cbChoise.height)/2));
		}		
			
		cbChoise.move(point.x, point.y);			
    }
    
	private function calcSize(mode:String='toCenter'):void
	{
		_connectorPoly = [];
		
		if(!fromObject && !toObject || !parent)
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

		switch(mode)
		{
   			case CM_CENTER:
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
		   		break;
	   	
		   	case CM_NEAREST:
		   	default:
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
		   		break;
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
		
		var ls1:LineSegment = new LineSegment(_connectorPoly[0], _connectorPoly[1]);								
		var ls2:LineSegment = new LineSegment(_connectorPoly[2], _connectorPoly[3]);
										
		var crossP:Point = ls1.intersection(ls2, false);
		var midP:Point = Point.interpolate(crossP, _connectorPoly[1], 0.6);
		
		if(focusColor>=0 && _enabled)
		{
			// Draw outline
			graphics.lineStyle(getStyle("strokeWidth") + getStyle("focusThickness")*2, 
				focusColor, getStyle("focusAlpha"));
				
			graphics.moveTo( _connectorPoly[0].x, _connectorPoly[0].y );
			graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );			
								
			graphics.lineTo( _connectorPoly[2].x, _connectorPoly[2].y );
			graphics.lineTo( midP.x, midP.y );
			graphics.lineTo( _connectorPoly[3].x, _connectorPoly[3].y );
			graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );									
		}
		else
		{
			graphics.lineStyle(getStyle("strokeWidth")+2, 0xffffff, 0.6, false, "normal", CapsStyle.NONE, JointStyle.MITER);	
						
			graphics.moveTo( _connectorPoly[0].x, _connectorPoly[0].y );
			graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );
								
			graphics.lineTo( _connectorPoly[2].x, _connectorPoly[2].y );
			graphics.lineTo( midP.x, midP.y );
			graphics.lineTo( _connectorPoly[3].x, _connectorPoly[3].y );
			graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );	
		}
		
		// Draw arrow		

		graphics.lineStyle(getStyle("strokeWidth"), color, getStyle("alpha"), false, "normal", CapsStyle.NONE, JointStyle.MITER);	
					
		graphics.moveTo( _connectorPoly[0].x, _connectorPoly[0].y );
		graphics.beginFill(color, getStyle("alpha"));
		graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );					
		graphics.lineTo( _connectorPoly[2].x, _connectorPoly[2].y );
		graphics.lineTo( midP.x, midP.y );
		graphics.lineTo( _connectorPoly[3].x, _connectorPoly[3].y );
		graphics.lineTo( _connectorPoly[1].x, _connectorPoly[1].y );	
		graphics.endFill();  
		
		//graphics.drawRect(0,0,getExplicitOrMeasuredWidth(),getExplicitOrMeasuredHeight());
	}			
    
    /**
     *  Called when the user starts dragging an connector
     */
    private function startDragging():void
    {	        
        systemManager.addEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        systemManager.addEventListener(
            MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
    }

    /**
     *  Called when the user stops dragging an connector
     */
    private function stopDragging():void
    {
        systemManager.removeEventListener(
            MouseEvent.MOUSE_MOVE, systemManager_mouseMoveHandler, true);

        systemManager.removeEventListener(
            MouseEvent.MOUSE_DOWN, systemManager_mouseDownHandler);
    }
    	    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function mouseDownHandler(event:MouseEvent):void
    {
    	if(event.altKey)
    	{
	    	var fromObj:Object = fromObject;
	    	dispose();
	    	
    		if(fromObj && fromObj is Node)
    			Node(fromObj).beginTransition();
    	}
    }
    
    private function mouseOverHandler(event:MouseEvent):void
    {
    	event.stopPropagation();
		
		if(_interactive) {
    		_over = true;
			invalidateDisplayList();
		}	
    }	
    
    private function mouseOutHandler(event:MouseEvent):void
    {	
    	_over = false;
		invalidateDisplayList();
    }
    
    private function objectUpdateHandler(event:Event):void
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
				remove();
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

    private function systemManager_mouseMoveHandler(event:MouseEvent):void
    {
    	event.stopImmediatePropagation();
    	invalidateSize();
    }		

    private function systemManager_mouseDownHandler(event:MouseEvent):void
    {
    	if(!fromObject || !toObject) 
    	{
    		fromObject = null;
    		toObject = null;
    	}
    }	
    
	private function systemManager_keyDownHandler(event:KeyboardEvent):void
    {
	    if(	event.keyCode == Keyboard.ESCAPE && 
	    	(!toObject || !fromObject))
	    {
	    	fromObject = null;
	    	toObject = null;
	    }		 
	}
	
	private function contextHandler(event:MouseEvent):void
	{
       	for each (var item:NativeMenuItem in contextMenu.items) {
       		item.label = LanguageManager.sentences['connector_'+item.name];
       	}
       	
       	if(_label)
       		contextMenu.getItemByName('select_trans').enabled = true;
       	else	
       		contextMenu.getItemByName('select_trans').enabled = false;
	}
	
	override protected function keyDownHandler(event:KeyboardEvent):void
    {
		if(event.keyCode == Keyboard.DELETE)
     	{
	    	event.stopPropagation();
     		remove();
	    }
	    else if(event.keyCode == Keyboard.ENTER)
	    {	
	    	event.stopPropagation();	    	
	    	beginEdit(false);
	    }
	    else if(event.keyCode == Keyboard.A && (event.commandKey || event.controlKey))
	    {
	    	event.stopPropagation();
	    	if(parent)
	    		parent.dispatchEvent(new Event("selectAll"))
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
    
    /**
     *  @private
     */
    override protected function focusInHandler(event:FocusEvent):void
    {
    	if(!_interactive) {
    		event.preventDefault();
    	}
		else
		{    		
    		_focused = true;
    	
        	super.focusInHandler(event);

        	invalidateDisplayList();
  		}
    }    	
}
}