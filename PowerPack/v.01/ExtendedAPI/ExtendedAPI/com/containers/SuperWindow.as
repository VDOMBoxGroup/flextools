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
import mx.managers.SystemManager;
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

    //----------------------------------
    //  windows
    //----------------------------------
    		
	public static function get windows():Array
	{
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
					
				superWindows.push(win);				
			}
		}
		
		return superWindows; 	
	}	
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
	
	public static function getWindow(value:NativeWindow):Window
	{
		if( value && value.stage.numChildren>0 )
		{
			var obj:Object = (value as NativeWindow).stage.getChildAt(0);
			var sm:WindowedSystemManager =  obj as WindowedSystemManager;
			
			if(!sm)
				return null;
				
			var win:Window = sm.window as Window;
			if(!win)
				return null;
				
			return win			
		}
		
		return null;		
	}
	
	public function setPosition():void
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
		setPosition();
	} 
	
	public static function getChildren(window:NativeWindow):Array
	{
		var wins:Array = SuperWindow.windows;
		var _children:Array = [];
		
		for each(var win:SuperWindow in wins)
		{
			if(win.parentWindow == window)
				_children.push(win);		
		}
		
		return _children;
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
	
	public function getBranch():Array
	{
		var superWins:Array = SuperWindow.windows;
		var branch:Array = [];
		var wins:Array = [];	
		
		for(var i:int=0; i<superWins.length; i++)
			wins.push( {'window':superWins[i], 'checked':false} );		
		
		getBranchRecursive(this.nativeWindow, wins, branch);
		
		return branch;
	}
	
	private function getBranchRecursive(window:NativeWindow, windows:Array, branch:Array):void
	{
		for(var i:int=0; i<windows.length; i++)
		{
			if(window == windows[i].window.nativeWindow && !windows[i].checked)
			{
				branch.unshift(window);
				windows[i].checked = true;
				if(windows[i].window.parentWindow)
					getBranchRecursive(windows[i].window.parentWindow, windows, branch);		
			}
		}
	}

	public function bringToFrontBranch():void
	{
		var branch:Array = this.getBranch();
		
		for(var i:int=0; i<branch.length; i++)
			NativeWindow(branch[i]).orderToFront();
	}
	
	public function bringToFrontChildren():void
	{
		var superWins:Array = SuperWindow.windows;
		var wins:Array = [];	
		
		for(var i:int=0; i<superWins.length; i++)
			wins.push( {'window':superWins[i], 'checked':false} );	
		
		bringToFrontChildrenRecursive(this.nativeWindow, wins);
	}
	
	private function bringToFrontChildrenRecursive(window:NativeWindow, windows:Array):void
	{
		window.orderToFront();		
		
		for(var i:int=0; i<windows.length; i++)
		{
			if(window == windows[i].window.parentWindow && !windows[i].checked)
			{
				windows[i].checked = true;								
				bringToFrontChildrenRecursive(windows[i].window.nativeWindow, windows);		
			}
		}
	}
		
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

	private function onDeactivate(event:Event):void {					
		var active:NativeWindow = NativeApplication.nativeApplication.activeWindow;
		var inactive:SuperWindow = event.target as SuperWindow;
		
		if(	inactive && inactive.nativeWindow && 
			!inactive.nativeWindow.closed && 
			inactive.parent && inactive._modal) {
			var indexA:int = getIndex(active);
			var indexI:int = inactive.index;
			if(indexA>=0 && indexI>=0 && indexI>indexA) {				
				inactive.activate();
				inactive.nativeWindow.notifyUser(NotificationType.CRITICAL);
			}		
		}				
	}

	private function onActivate(event:Event):void {
		
		for each (var win:SuperWindow in SuperWindow.windows)
		{
			if(win.modal && !win.closed && win.nativeWindow && win.parent && SuperWindow.getIndex(win)>SuperWindow.getIndex(this))
			{
				win.activate();
				return;
			}			
		}
		
		if(nativeWindow)
		{
			bringToFrontBranch();				
			bringToFrontChildren();
		}
	}	
	
}
}