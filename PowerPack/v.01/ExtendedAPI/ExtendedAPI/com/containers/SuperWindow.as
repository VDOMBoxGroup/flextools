package ExtendedAPI.com.containers
{
import flash.desktop.NativeApplication;
import flash.desktop.NotificationType;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.Screen;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.IWindow;
import mx.core.Window;
import mx.core.mx_internal;
import mx.events.AIREvent;
import mx.managers.WindowedSystemManager;

use namespace mx_internal;

public class SuperWindow extends Window implements IWindow
{
	public static const POS_MANUAL:String = "manual";
	public static const POS_CENTER_SCREEN:String = "centerScreen";
	public static const POS_CENTER_PARENT:String = "centerParent";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
	public function SuperWindow(parentWindow:NativeWindow=null)
	{
		super();
		
		this.parentWindow = parentWindow;
		
		addEventListener(AIREvent.WINDOW_DEACTIVATE, onDeactivate);
		addEventListener(AIREvent.WINDOW_ACTIVATE, onActivate);
	}
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  parentWindow
    //----------------------------------

	private var _parentWindowChanged:Boolean;
	private var _parentWindow:NativeWindow;  
	
	[Bindable("parentWindowChanged")]
	public function get parentWindow():NativeWindow
	{
		return _parentWindow;
	}
	public function set parentWindow(value:NativeWindow):void
	{
		if(_parentWindow!=value)
		{
			_parentWindow = value;
			_parentWindowChanged = true;
			
			_parentWindow.removeEventListener(Event.ACTIVATE, onActivate);
			_parentWindow.addEventListener(Event.ACTIVATE, onActivate);
			
			invalidateProperties();
			dispatchEvent(new Event("parentWindowChanged"));
		}
	}
	
    //----------------------------------
    //  modal
    //----------------------------------

	private var _modalChanged:Boolean;
	private var _modal:Boolean;  
	
	[Bindable("modalChanged")]
	[Inspectable(category="General", enumeration="true,false", defaultValue="false")]
	public function get modal():Boolean
	{
		return _modal;
	}
	public function set modal(value:Boolean):void
	{
		if(_modal!=value)
		{
			_modal = value;
			_modalChanged = true;
			
			invalidateProperties();
			dispatchEvent(new Event("modalChanged"));
		}
	}
    
    //----------------------------------
    //  startPosition
    //----------------------------------

	private var _startPositionChanged:Boolean;
	private var _startPosition:String = POS_MANUAL;  
	
	[Bindable("startPositionChanged")]
	[Inspectable(category="General", enumeration="manual,centerParent,centerScreen", defaultValue="manual")]
	public function get startPosition():String
	{
		return _startPosition;
	}
	public function set startPosition(value:String):void
	{
		if(_startPosition!=value)
		{
			_startPosition = value;
			_startPositionChanged = true;
			
			invalidateProperties();
			dispatchEvent(new Event("startPositionChanged"));
		}
	}
							
    //----------------------------------
    //  index
    //----------------------------------

	public function get index():int
	{
		return getIndex(this.nativeWindow);
	}
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

	private function setStartPosition():void
	{
		if(!nativeWindow || nativeWindow.closed)
			return;
			
		var width:int = nativeWindow.width;
		var height:int = nativeWindow.height;
		
		var parentRect:Rectangle = Screen.mainScreen.visibleBounds;

		switch(_startPosition)
		{
			case POS_CENTER_PARENT:
				if(	parentWindow && !parentWindow.closed && 
					parentWindow.visible && 
					parentWindow.displayState==NativeWindowDisplayState.NORMAL)
				{
					parentRect = new Rectangle(parentWindow.x, parentWindow.y, 
						parentWindow.width, parentWindow.height);							
				}
			case POS_CENTER_SCREEN:
				nativeWindow.x = parentRect.x + (parentRect.width-width)/2;
				nativeWindow.y = parentRect.y + (parentRect.height-height)/2;
				break;
		}
	}
	
	override public function open(openWindowAcive:Boolean=true):void
	{
		super.open(openWindowAcive);
		setStartPosition();
	} 
	
	public static function getIndex(window:Object):int
	{
		if(window is Window)
			window = Window(window).nativeWindow;
		
		var windows:Array = NativeApplication.nativeApplication.openedWindows;
		for(var i:int=0; i<windows.length; i++) {
			if(window==windows[i]) {
				return i 
			}
		}
		return -1;
	}

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

	private function onDeactivate(event:Event):void {					
		var active:NativeWindow = NativeApplication.nativeApplication.activeWindow;
		var inactive:SuperWindow = event.target as SuperWindow;
		
		if(inactive && inactive.nativeWindow && !inactive.nativeWindow.closed && 
			inactive.parent && inactive._modal) {
			var indexA:int = getIndex(active);
			var indexI:int = inactive.index;
			if(indexI>=0 && indexI>indexA) {
				inactive.activate();
				inactive.nativeWindow.notifyUser(NotificationType.CRITICAL);
			}		
		}				
	}

	private function onActivate(event:Event):void {					
		var active:NativeWindow = NativeApplication.nativeApplication.activeWindow;
		var windows:Array = NativeApplication.nativeApplication.openedWindows;
		var superWindows:Array = [];		

		for(var i:int=0; i<windows.length; i++) {			
			if( (windows[i] as NativeWindow).stage.numChildren>0 )
			{
				var sm:WindowedSystemManager = (windows[i] as NativeWindow).stage.getChildAt(0) as WindowedSystemManager;
				if(!sm)
					continue;
					
				var win:SuperWindow = sm.window as SuperWindow;
				if(!win)
					continue;
					
				superWindows.push({'window':win, 'checked':false});				
			}
		}
		
		bringToFrontChildren(active, superWindows);
	}
	
	public static function bringToFrontChildren(window:NativeWindow, windows:Array):void
	{
		for(var i:int=0; i<windows.length; i++)
		{
			if(window == windows[i].window.parentWindow && !windows[i].checked)
			{
				windows[i].checked = true;
				SuperWindow(windows[i].window).orderToFront();
				bringToFrontChildren(SuperWindow(windows[i].window).nativeWindow, windows);				
			}
		}
	}	
}
}