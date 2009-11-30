package net.vdombox.utils
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.events.AIREvent;
	
	import spark.components.Window;
	import spark.components.WindowedApplication;

	public class WindowManager
	{
		private static var instance : WindowManager;

		private var windowsInfo : Array;

		private var handlerDictionary : Dictionary;

		private var lastActiveWindow : NativeWindow;

		/**
		 *
		 * @return instance of AlertManager class ( Singleton )
		 *
		 */
		public static function getInstance() : WindowManager
		{
			if ( !instance )
			{
				instance = new WindowManager();
			}

			return instance;
		}

		/**
		 *
		 * Constructor
		 *
		 */
		public function WindowManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );
		}

		public function createWindow( content : UIComponent, title : String, parent : UIComponent = null, 
									  isModal : Boolean = true, childList : String = null, windowOptions : NativeWindowInitOptions = null ) : Window
		{
			if ( !windowsInfo )
				windowsInfo = [];

			if ( !handlerDictionary )
				handlerDictionary = new Dictionary();

			const windowData : WindowData = new WindowData();
			const window : Window = new Window();

			windowData.content = content;
			windowData.parent = parent;
			windowData.isModal = parent == null ? false : isModal;

			window.systemChrome = NativeWindowSystemChrome.NONE;
			window.transparent = true;

			if ( windowOptions )
			{
				try
				{
					window.maximizable = windowOptions.maximizable;
					window.minimizable = windowOptions.minimizable;
					window.resizable = windowOptions.resizable;
					window.systemChrome = windowOptions.systemChrome;
					window.transparent = windowOptions.transparent;
					window.type = windowOptions.type;
				}
				catch ( error : Error )
				{
				}
			}

			window.visible = false;
			window.title = title;

			window.addElement( windowData.content as IVisualElement );

			window.addEventListener( AIREvent.WINDOW_COMPLETE, window_windowCompleteHandler );
			window.open( false );

			windowData.nativeWindow = window.nativeWindow;

			windowsInfo.push( windowData );
			return window;
		}
		
		public function addWindow( window : Window, parent : UIComponent = null, isModal : Boolean = false ) : void
		{
			if ( !windowsInfo )
				windowsInfo = [];
			
			if ( !handlerDictionary )
				handlerDictionary = new Dictionary();
			
			const windowData : WindowData = new WindowData();
			
			windowData.parent = parent;
			windowData.isModal = parent == null ? false : isModal;
			
			
			window.visible = false;
			
			window.addEventListener( AIREvent.WINDOW_COMPLETE, window_windowCompleteHandler );
			window.open( false );
			
			windowData.nativeWindow = window.nativeWindow;
			
			windowsInfo.push( windowData );
		}
		
//		public function addWi
		
		public function removeWindow( component : * ) : void
		{
			var nativeWindow : NativeWindow;

			if ( component is Window )
			{
				try
				{
					nativeWindow = Window( component ).nativeWindow;
				}
				catch ( error : Error )
				{
				}
			}
			else if ( component is UIComponent )
			{
				try
				{
					nativeWindow = component.stage.nativeWindow;
				}
				catch ( error : Error )
				{
				}
			}
			else if ( component is NativeWindow )
			{
				nativeWindow = component as NativeWindow;
			}

			if ( nativeWindow != null )
				closeWindow( nativeWindow );
		}

		public function removeAllWindows() : void
		{
			if ( !windowsInfo )
				return;

			while ( windowsInfo.length > 0 )
			{
				closeWindow( WindowData( windowsInfo[ 0 ]).nativeWindow );
			}
		}

		private function fitToContent( window : Window, content : UIComponent ) : void
		{
			var oldWidth : Number = window.width;
			var oldHeight : Number = window.height;

			var containerWidth : Number = Math.max( content.width, content.getExplicitOrMeasuredWidth());

			var containerHeight : Number = Math.max( content.height, content.getExplicitOrMeasuredHeight());

//			var vm : EdgeMetrics = window.vie

			window.minWidth = content.minWidth; //+ vm.left + vm.right;
			window.minHeight = content.minHeight; //+ vm.top + vm.bottom;

			window.width = containerWidth; //+ vm.left + vm.right;
			window.height = containerHeight; //+ vm.top + vm.bottom;

		}

		private function windowIsLocked( nativeWindow : NativeWindow ) : Boolean
		{
			var isLockedWindow : Boolean = windowsInfo.some( 
				function( element : *, index : int, arr : Array ) : Boolean
				{
					var parent : UIComponent = element.parent;

					if ( !element.isModal || parent == null || parent.stage == null )
						return false;

					var parentNativeWindow : NativeWindow = parent.stage.nativeWindow;

					if ( parentNativeWindow && parentNativeWindow == nativeWindow )
						return true;

					return false;
				});

			return isLockedWindow;
		}

		private function changeWindowsDisplayState( displayState : String ) : void
		{
			var visible : Boolean = false;
			var length : int = windowsInfo.length;

			if ( displayState == NativeWindowDisplayState.MAXIMIZED )
			{
				visible = true;
			}
			else if ( displayState != NativeWindowDisplayState.MINIMIZED )
			{
				return;
			}

			for ( var i : uint = 0; i < length; i++ )
			{
				WindowData( windowsInfo[ i ]).nativeWindow.visible = visible;
			}
		}

		private function centerPopUp( window : Window ) : void
		{
			var screen : Screen = Screen.getScreensForRectangle( window.nativeWindow.bounds )[ 0 ];

			window.move( Math.max( screen.bounds.width / 2 - window.width / 2, 0 ), Math.max( screen.bounds.height / 2 - window.height / 2, 0 ));
		}

		private function findWindowInfoByWindow( nativeWindow : NativeWindow ) : WindowData
		{
			const n : int = windowsInfo.length;
			for ( var i : int = 0; i < n; i++ )
			{
				var o : WindowData = windowsInfo[ i ];
				if ( o.nativeWindow == nativeWindow )
					return o;
			}
			return null;
		}

		private function findFirstModalWindowInfoByParentWindow( parentNativeWindow : NativeWindow ) : WindowData
		{
			const n : int = windowsInfo.length;
			
			for ( var i : int = 0; i < n; i++ )
			{
				var windowData : WindowData = windowsInfo[ i ];
				
				if ( windowData.parent == null )
					continue;
				
				var parentNativeWindow : NativeWindow = NativeWindow( windowData.parent.stage.nativeWindow );
				
				if ( windowData.isModal && parentNativeWindow == parentNativeWindow )
					return windowData;
			}
			return null;
		}

		private function findAllModalPopupInfoByParentWindow( parentNativeWindow : NativeWindow ) : Array
		{
			var newArr : Array = windowsInfo.filter( function( element : *, index : int, arr : Array ) : Boolean
				{
					return parentNativeWindow == element.parent.stage.nativeWindow;
				})
			return newArr;
		}

		private function closeWindow( nativeWindow : NativeWindow ) : void
		{
			var windowData : WindowData = findWindowInfoByWindow( nativeWindow );

			if ( windowData == null )
				return;

			nativeWindow.removeEventListener( Event.CLOSE, nativeWindow_closeHandler );

			windowData.content.dispatchEvent( new Event( Event.CLOSE ));
			ArrayUtils.removeValueFromArray( windowsInfo, windowData );
			removeHandlers( nativeWindow );

			if ( !nativeWindow.closed )
				nativeWindow.close();

			if ( windowData.parent == null )
				return;

			var parentNativeWindow : NativeWindow = windowData.parent.stage.nativeWindow;
			var isLockedWindow : Boolean = windowIsLocked( parentNativeWindow );

			if ( !isLockedWindow )
			{
				if ( windowData.parent.parentApplication != null )
					windowData.parent.parentApplication.enabled = true;
				else
					windowData.parent.enabled = true;
			}
		}

		private function addHandlers( nativeWindow : NativeWindow, handlers : Array ) : void
		{
			handlerDictionary[ nativeWindow ] = handlers;

			handlers.forEach( function( element : *, index : int, arr : Array ) : void
				{
					nativeWindow.addEventListener( element[ "type" ], element[ "handler" ]);
				})
		}

		private function removeHandlers( nativeWindow : NativeWindow ) : void
		{
			var handlers : Array = handlerDictionary[ nativeWindow ];
			if ( handlers == null )
				return;

			handlers.forEach( function( element : *, index : int, arr : Array ) : void
				{
					nativeWindow.removeEventListener( element[ "type" ], element[ "handler" ]);
				})
		}

		private function nativeWindow_activateHandler( event : Event ) : void
		{
			var currentNativeWindow : NativeWindow = event.currentTarget as NativeWindow;

			if ( currentNativeWindow && currentNativeWindow == lastActiveWindow )
				return;

			var ppuwd : WindowData = findFirstModalWindowInfoByParentWindow( currentNativeWindow );
			var isModal : Boolean = false;

			if ( ppuwd && ppuwd.isModal && lastActiveWindow && !lastActiveWindow.closed )
			{
				lastActiveWindow.activate();
				currentNativeWindow.orderInBackOf( ppuwd.nativeWindow );
				isModal = true;
			}

			var cpuwd : WindowData = findWindowInfoByWindow( currentNativeWindow );

			if ( cpuwd == null )
				return;

			if ( isModal )
			{
				ArrayUtils.removeValueFromArray( windowsInfo, cpuwd );
				var pi : int = windowsInfo.indexOf( ppuwd );
				var arr1 : Array = windowsInfo.slice( 0, pi );
				var arr2 : Array = windowsInfo.slice( pi );
				windowsInfo = arr1.concat( cpuwd, arr2 );
			}
			else
			{
				ArrayUtils.removeValueFromArray( windowsInfo, cpuwd );
				windowsInfo.push( cpuwd );
				lastActiveWindow = currentNativeWindow;
			}
		}

		private function nativeWindow_displayStateChangingHandler( event : NativeWindowDisplayStateEvent ) : void
		{
			if ( !windowsInfo || windowsInfo.length == 0 )
				return;

			var currentNativeWindow : NativeWindow = event.currentTarget as NativeWindow;
			if ( currentNativeWindow == null )
				return;

			var isLockedWindow : Boolean = windowIsLocked( currentNativeWindow );

			if ( isLockedWindow )
			{
				event.preventDefault();
				return;
			}
			var nativeWindow : NativeWindow = WindowedApplication( FlexGlobals.topLevelApplication ).nativeWindow;

			if ( currentNativeWindow == nativeWindow )
			{
				if ( event.afterDisplayState == NativeWindowDisplayState.MINIMIZED )
				{
					changeWindowsDisplayState( NativeWindowDisplayState.MINIMIZED );
				}
				else if ( event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED )
				{
					changeWindowsDisplayState( NativeWindowDisplayState.MAXIMIZED );
				}
			}
		}

		private function window_windowCompleteHandler( event : AIREvent ) : void
		{
			var window : Window = event.currentTarget as Window;
			window.removeEventListener( AIREvent.WINDOW_COMPLETE, window_windowCompleteHandler );

			var nativeWindow : NativeWindow = window.nativeWindow;

			var windowData : WindowData = findWindowInfoByWindow( nativeWindow );

			if ( !windowData )
				return;

//			fitToContent( window, puwd.content );
			centerPopUp( window );

			var handlers : Array = 
				[
					{ type: Event.CLOSE, handler: nativeWindow_closeHandler }, 
					{ type: Event.ACTIVATE, handler: nativeWindow_activateHandler }
				];

			addHandlers( nativeWindow, handlers );

			if ( windowData.parent == null )
			{
				window.visible = true;
				nativeWindow.activate();
				return;
			}

			var parentNativeWindow : NativeWindow = windowData.parent.stage.nativeWindow;
			var isParentWindowLocked : Boolean = windowIsLocked( parentNativeWindow );

			if ( isParentWindowLocked && windowData.isModal )
			{
				var parentHandlers : Array = 
					[
						{ type: NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, handler: nativeWindow_displayStateChangingHandler }, 
						{ type: Event.CLOSING, handler: parent_closingHandler }, { type: Event.ACTIVATE, handler: nativeWindow_activateHandler }
					];

				addHandlers( parentNativeWindow, parentHandlers );

				if ( windowData.parent.parentApplication )
					windowData.parent.parentApplication.enabled = false;
				else
					windowData.parent.enabled = false;
			}

			if ( handlerDictionary[ parentNativeWindow ] === undefined )
			{
				parentNativeWindow.addEventListener( Event.ACTIVATE, nativeWindow_activateHandler );
				handlerDictionary[ parentNativeWindow ] = [{ type: Event.ACTIVATE, handler: nativeWindow_activateHandler }];
			}

			window.visible = true;
			nativeWindow.activate();
		}

		private function nativeWindow_closeHandler( event : Event ) : void
		{
			var currentNativeWindow : NativeWindow = event.currentTarget as NativeWindow;

			closeWindow( currentNativeWindow );
		}

		private function parent_closingHandler( event : Event ) : void
		{
			var currentNativeWindow : NativeWindow = event.currentTarget as NativeWindow;
			if ( currentNativeWindow == null )
				return;

			var isLocked : Boolean = windowIsLocked( currentNativeWindow );

			if ( isLocked )
			{
				event.preventDefault();
				event.stopImmediatePropagation();
			}
		}
	}
}


import flash.display.NativeWindow;
import flash.events.Event;

import mx.core.IVisualElement;
import mx.core.UIComponent;


class WindowData
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function WindowData()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	public var nativeWindow : NativeWindow;

	public var content : UIComponent;

	public var parent : UIComponent;

	public var isModal : Boolean;
}