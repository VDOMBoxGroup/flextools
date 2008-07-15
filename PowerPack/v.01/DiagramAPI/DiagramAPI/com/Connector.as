package DiagramAPI.com
{
import DiagramAPI.com.baseClasses.InteractivePoint;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.ListCollectionView;
import mx.controls.ComboBox;
import mx.core.Application;
import mx.core.Container;
import mx.core.UIComponent;
import mx.events.DropdownEvent;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.managers.IFocusManagerComponent;
import mx.managers.PopUpManager;

//--------------------------------------
//  Events
//--------------------------------------	

//--------------------------------------
//  Styles
//--------------------------------------

//--------------------------------------
//  Other metadata
//--------------------------------------

//[IconFile("Connector.png")]

public class Connector extends InteractiveConnector implements IFocusManagerComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------		
    
    private static var modalTransparencyBlur:Number;
    private static var modalTransparency:Number;
    
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
		styleName = this.className;	
		cacheAsBitmap = true;
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
       	dispatchEvent(new ConnectorEvent(ConnectorEvent.DISPOSED));
	}	

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

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
    	}
    }

    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object;
    private var _dataChanged:Boolean;	  

    [Bindable("dataChanged")]
    [Inspectable(category="General")]

    override public function get data():Object
    {
        return _data;
    }
    override public function set data(value:Object):void
    {
    	if(_data != value)
    	{
        	_data = value;
        	_dataChanged = true;	   
        	
        	invalidateProperties();
        	      
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.DATA_CHANGED));
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
			if(_fromObj) {
       			_fromObj.removeEventListener(ResizeEvent.RESIZE, objectPositionSizeChanged); 
       			_fromObj.removeEventListener("xChanged", objectPositionSizeChanged);
       			_fromObj.removeEventListener("yChanged", objectPositionSizeChanged);
       			_fromObj.removeEventListener(Event.REMOVED, objectPositionSizeChanged);
   			}

        	_fromObj = value;
        	_fromObjChanged = true;
			
			if(_fromObj) {
       			_fromObj.addEventListener(ResizeEvent.RESIZE, objectPositionSizeChanged); 
       			_fromObj.addEventListener("xChanged", objectPositionSizeChanged);
       			_fromObj.addEventListener("yChanged", objectPositionSizeChanged);
       			_fromObj.addEventListener(Event.REMOVED, objectPositionSizeChanged);
   			}
        
	        invalidateProperties();
			         
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
			if(_toObj) {
       			_toObj.removeEventListener(ResizeEvent.RESIZE, objectPositionSizeChanged); 
       			_toObj.removeEventListener("xChanged", objectPositionSizeChanged);
       			_toObj.removeEventListener("yChanged", objectPositionSizeChanged);
       			_toObj.removeEventListener(Event.REMOVED, objectPositionSizeChanged);
   			}
   			    		
        	_toObj = value;
    	    _toObjChanged = true;

			if(_toObj) {
       			_toObj.addEventListener(ResizeEvent.RESIZE, objectPositionSizeChanged); 
       			_toObj.addEventListener("xChanged", objectPositionSizeChanged);
       			_toObj.addEventListener("yChanged", objectPositionSizeChanged);
       			_toObj.addEventListener(Event.REMOVED, objectPositionSizeChanged);
   			}        
   			
	        invalidateProperties();
			         
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.TO_OBJECT_CHANGED));
     	}
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
    }

    override protected function commitProperties():void
    {
        super.commitProperties();
        	        
        if (_labelChanged)
        {
            _labelChanged = false;
            toolTip = label;

           invalidateDisplayList();
        }
        
        if (_dataChanged)
        {
            _dataChanged = false;

           invalidateDisplayList();
        }       

        if(_fromObjChanged || _toObjChanged)
        {
			_fromObjChanged = false;
			_toObjChanged = false;
			
			systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, objectPositionSizeChanged);
			
			if(!fromObject || !toObject) {
				systemManager.addEventListener(MouseEvent.MOUSE_MOVE, objectPositionSizeChanged);	
			}			
			
			calcAnchors();
			
			invalidateSize();
			invalidateDisplayList();			
        }
    }
    
	override protected function measure():void 
	{
		calcAnchors();
		
        super.measure();
        
   		invalidateDisplayList();
    }  	    		
   
	// Override updateDisplayList() to update the component 
	override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);	
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
				
	private function calcAnchors():void
	{		
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
			
			p1 = fromObject.localToContent(p1);
			
			fromRect = new Rectangle(
				p1.x,
				p1.y,
				fromObject.width,
				fromObject.height );
			
			fromP = Point.interpolate(fromRect.topLeft, fromRect.bottomRight, 0.5);
   		}
   		   			
   		if(toObject)
   		{
			var p2:Point = new Point(				
				toObject.x,
				toObject.y);

			p2 = toObject.localToContent(p2);

			toRect = new Rectangle(
				p2.x,
				p2.y,
				toObject.width,
				toObject.height);
   			
			toP = Point.interpolate(toRect.topLeft, toRect.bottomRight, 0.5);
   		}

   		fromRect.width += fromRect.width>0?0:1;
   		fromRect.height += fromRect.height>0?0:1;
   		toRect.width += toRect.width>0?0:1;
   		toRect.height += toRect.height>0?0:1;
   		
   		if(fromRect.intersects(toRect))
   			return;
   		
   		var rect:Rectangle = new Rectangle();
   		rect.topLeft = fromP;
   		rect.bottomRight = toP;
   		
   		rect.width += rect.width>0?0:1;
   		rect.height += rect.height>0?0:1;
   		
   		var intersect:Rectangle;
   		
   		var koef:Number = rect.width/rect.height;
   		var koef1:Number = fromRect.width/fromRect.height;
   		var koef2:Number = toRect.width/toRect.height;
   		
   		intersect = fromRect.intersection(rect);
   		fromP.x += (intersect.left==fromP.x?1:-1)*intersect.width * (koef>koef1?1:koef/koef1);	
   		fromP.y += (intersect.top==fromP.y?1:-1)*intersect.height * (koef>koef1?koef1/koef:1);	
   		
   		intersect = toRect.intersection(rect);
   		toP.x += (intersect.left==toP.x?1:-1)*intersect.width * (koef>koef2?1:koef/koef2);	
   		toP.y += (intersect.top==toP.y?1:-1)*intersect.height * (koef>koef2?koef2/koef:1);   		
   			
		InteractivePoint(_anchorPoints[0])._context.moveToPoint(parent, fromP)
		InteractivePoint(_anchorPoints[1])._context.moveToPoint(parent, toP)
	}
	
    public function beginEdit(atCursorPosition:Boolean = true, position:Point = null):void
    {	
    	if(!data)
    		return;
    	
    	var arr:Array = [];
    	
		if(data is Array)
			arr = data as Array;
		else if(data is ListCollectionView)
			arr = (data as ListCollectionView).toArray();
		else
			arr.push(data);
		
		var cbChoise:ComboBox = new ComboBox();
		cbChoise.dataProvider = arr;
		cbChoise.addEventListener(DropdownEvent.CLOSE, dropDownCloseHandler);
		cbChoise.addEventListener(FlexEvent.CREATION_COMPLETE, comboBoxCreatedHandler);
		
		modalTransparencyBlur = Application.application.getStyle("modalTransparencyBlur");
		modalTransparency = Application.application.getStyle("modalTransparency");
					
		Application.application.setStyle("modalTransparencyBlur", 0);
		Application.application.setStyle("modalTransparency", 0);
		
		PopUpManager.addPopUp(cbChoise, parent, true);
		
		if(label)
		{
			for(var i:int=0; i<arr.length; i++)
			{
				if(arr[i].toString()==label)
				{ 
					cbChoise.selectedIndex = i; 
					break;
				}
			}
		}
		
		var point:Point = atCursorPosition ? localToGlobal(new Point(mouseX, mouseY)) : 
			Container(parent).contentToGlobal(new Point(x+width/2, y+height/2));
		
		if(position)
			point = position;
			
		cbChoise.move(point.x, point.y);			
    }	    
    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
 	
 	private function objectPositionSizeChanged(event:Event):void
 	{
 		invalidateSize();
 		invalidateDisplayList();		
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
    
}
}