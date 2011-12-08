package net.vdombox.powerpack.lib.ExtendedAPI.containers
{
import flash.display.NativeWindow;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;

public class SuperAlert extends SuperWindow
{
    private static var modalTransparencyBlur:Number;
    private static var modalTransparency:Number;
          
    public static function show(text:String = "", title:String = "",
                                flags:uint = 0x4 /* Alert.OK */, 
                                parent:NativeWindow = null, 
                                closeHandler:Function = null, 
                                iconClass:Class = null, 
                                defaultButtonFlag:uint = 0x4 /* Alert.OK */):SuperAlert
    {
        var modal:Boolean = (flags & Alert.NONMODAL) ? false : true;

        var alert:SuperAlert = new SuperAlert(parent);

        alert.modal = modal;
        alert.title = title;
        alert.icon = iconClass;

      	alert.addEventListener(Event.CLOSE, alert.alertCloseHandler);
                        
        if (closeHandler != null)
            alert._closeHandler = closeHandler;

		modalTransparencyBlur = Application.application.getStyle("modalTransparencyBlur");
		modalTransparency = Application.application.getStyle("modalTransparency");
		
		Application.application.setStyle("modalTransparencyBlur", 0);
		Application.application.setStyle("modalTransparency", 0);
		
		alert.open();	
		alert.activate();	

		alert.panel = Alert.show(text, title, flags, alert, alert.closeHandler, iconClass, defaultButtonFlag);
		alert.panel.addEventListener(ResizeEvent.RESIZE, alert.resizeHandler);
		alert.panel.addEventListener(MoveEvent.MOVE, alert.moveHandler);
		
		alert.invalidateSize();
		alert.invalidateDisplayList();
		
        return alert;
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */    
	public function SuperAlert(parentWindow:NativeWindow=null)
	{
		super(parentWindow);
		title = "";
		//type = NativeWindowType.LIGHTWEIGHT;
		systemChrome = NativeWindowSystemChrome.NONE;
		transparent = true;
		showTitleBar = false;
		showStatusBar = false;
		showGripper = false;
		resizable = false;
		
		setStyle('showFlexChrome' , false);
		
		startPosition = SuperWindow.POS_CENTER_PARENT;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	private var panel:Alert;
	
    private var positioned:Boolean = false;
    
    private var _closeHandler:Function;
    
    private var _event:CloseEvent;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function measure():void
    {   
        super.measure();		

    	if(panel)
    	{
    		var rect:Rectangle = panel.getBounds(this);
        
        	measuredMinWidth = measuredWidth = rect.width;        
        	measuredMinHeight = measuredHeight = rect.height;
     	}
     	  	
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
		width = measuredWidth+5;
		height = measuredHeight+5;	
		
		if(!positioned)
		{
			positioned = true;
			setPosition();
		}		                      
    }
    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function alertCloseHandler(event:Event):void
    {
    	event.stopImmediatePropagation();
    	removeEventListener(Event.CLOSE, alertCloseHandler);
    	
    	if(_closeHandler!=null)
    		addEventListener(CloseEvent.CLOSE, _closeHandler); 
    		   	
    	var closeEvent:CloseEvent = _event ? _event : new CloseEvent(CloseEvent.CLOSE);
    	dispatchEvent(closeEvent);    	
    } 
       
    /**
     *  @private
     */
    private function closeHandler(event:CloseEvent):void
    {    	
		Application.application.setStyle("modalTransparencyBlur", modalTransparencyBlur);
		Application.application.setStyle("modalTransparency", modalTransparency);
		    	
    	close();
    	
    	_event = event;
    }
    
    /**
     *  @private
     */    
    private function resizeHandler(event:ResizeEvent):void
    {
    	invalidateSize();
    }
    
    /**
     *  @private
     */
    private function moveHandler(event:MoveEvent):void
    {
    	this.nativeWindow.x += event.target.x - event.oldX
    	this.nativeWindow.y += event.target.y - event.oldY
    	
    	panel.x = 3;
    	panel.y = 3;
    	
		invalidateDisplayList();    	
    }
    
}
}