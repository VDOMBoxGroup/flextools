package net.vdombox.ide.core.view.managers
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.utils.Dictionary;
	
	import mx.core.EdgeMetrics;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.core.Window;
	import mx.events.AIREvent;
	
	import net.vdombox.utils.ArrayUtils;
	
	public class PopUpWindowManager
	{
		private static var instance : PopUpWindowManager;

		private var popUpInfo : Array;

		private var handlerDictionary : Dictionary;

		private var lastActiveWindow : NativeWindow;

		/**
		 *
		 * @return instance of AlertManager class ( Singleton )
		 *
		 */
		public static function getInstance() : PopUpWindowManager
		{
			if ( !instance )
			{
				instance = new PopUpWindowManager();
			}

			return instance;
		}

		/**
		 *
		 * Constructor
		 *
		 */
		public function PopUpWindowManager()
		{
			if ( instance )
				throw new Error( "Instance already exists." );

//			var nativeWindow : NativeWindow = Application.application.nativeWindow;
//			if ( nativeWindow )
//				nativeWindow.addEventListener( NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
//											   nativeWindow_displayStateChangingHandler );
		}

		public function addPopUp( content : UIComponent, title : String, parent : UIComponent = null,
								  modal : Boolean = true, childList : String = null,
								  windowOptions : NativeWindowInitOptions = null ) : Window
		{
			if ( !popUpInfo )
				popUpInfo = [];

			if ( !handlerDictionary )
				handlerDictionary = new Dictionary();

			const puwd : PopUpWindowData = new PopUpWindowData();
			const window : Window = new Window();

			puwd.content = content;
			puwd.parent = parent;
			puwd.isModal = parent == null ? false : modal;

			window.systemChrome = NativeWindowSystemChrome.NONE;
			window.transparent = true;
			window.styleName = "popUpWindow";

			if ( windowOptions != null )
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
			
			window.addChild( puwd.content );

			window.addEventListener( AIREvent.WINDOW_COMPLETE, window_windowCompleteHandler );
			window.open( false );

			puwd.nativeWindow = window.nativeWindow;

			popUpInfo.push( puwd );
			return window;
		}

		public function removePopUp( component : * ) : void
		{
			var nativeWindow : NativeWindow;

			if ( component is UIComponent )
			{
				try
				{
					nativeWindow = UIComponent( component ).stage.nativeWindow;
				}
				catch ( error : Error )
				{
				}
			}
			else if ( component is Window )
			{
				try
				{
					nativeWindow = Window( component ).nativeWindow;
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
		
		public function removeAllPopUp() : void
		{
			while ( popUpInfo.length > 0 )
			{
				closeWindow( PopUpWindowData( popUpInfo[ 0 ] ).nativeWindow );
			}
		}
		
		private function fitToContent( window : Window, content : UIComponent ) : void
		{
			var oldWidth : Number = window.width;
			var oldHeight : Number = window.height;

			content.validateNow();
			
			var containerWidth : Number = Math.max( content.width, content.getExplicitOrMeasuredWidth() );

			var containerHeight : Number = Math.max( content.height, content.getExplicitOrMeasuredHeight() );

			var vm : EdgeMetrics = window.viewMetricsAndPadding;
			
			window.minWidth = content.minWidth + vm.left + vm.right;
			window.minHeight = content.minHeight + vm.top + vm.bottom;
			
			window.width = containerWidth + vm.left + vm.right;
			window.height = containerHeight + vm.top + vm.bottom;
			
		}

		private function windowIsLocked( nativeWindow : NativeWindow ) : Boolean
		{
			var isLockedWindow : Boolean = popUpInfo.some( function( element : *,
																	 index : int,
																	 arr : Array ) : Boolean
				{
					var parent : UIComponent = element.parent;

					if ( !element.isModal || parent == null || parent.stage == null )
						return false;

					var pnw : NativeWindow = parent.stage.nativeWindow;

					if ( pnw && pnw == nativeWindow )
						return true;

					return false;
				} );

			return isLockedWindow;
		}

		private function changeWindowsDisplayState( displayState : String ) : void
		{
			var visible : Boolean = false;
			var length : int = popUpInfo.length;

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
				PopUpWindowData( popUpInfo[ i ] ).nativeWindow.visible = visible;
			}
		}

		private function centerPopUp( window : Window ) : void
		{
			var screen : Screen = Screen.getScreensForRectangle( window.nativeWindow.bounds )[ 0 ];

			window.move( Math.max( screen.bounds.width / 2 - window.width / 2, 0 ),
						 Math.max( screen.bounds.height / 2 - window.height / 2,
								   0 ) );
		}

		private function findPopupInfoByWindow( nativeWindow : NativeWindow ) : PopUpWindowData
		{
			const n : int = popUpInfo.length;
			for ( var i : int = 0; i < n; i++ )
			{
				var o : PopUpWindowData = popUpInfo[ i ];
				if ( o.nativeWindow == nativeWindow )
					return o;
			}
			return null;
		}

		private function findFirstModalPopupInfoByParentWindow( parentNativeWindow : NativeWindow ) : PopUpWindowData
		{
			const n : int = popUpInfo.length;
			for ( var i : int = 0; i < n; i++ )
			{
				var o : PopUpWindowData = popUpInfo[ i ];
				if ( o.parent == null )
					continue;
				var pnw : NativeWindow = o.parent.stage.nativeWindow;
				if ( o.isModal && pnw == parentNativeWindow )
					return o;
			}
			return null;
		}

		private function findAllModalPopupInfoByParentWindow( parentNativeWindow : NativeWindow ) : Array
		{
			var newArr : Array = popUpInfo.filter( function( element : *, index : int,
															 arr : Array ) : Boolean
				{
					return parentNativeWindow == element.parent.stage.nativeWindow;
				} )
			return newArr;
		}

		private function closeWindow( nativeWindow : NativeWindow ) : void
		{
			var o : PopUpWindowData = findPopupInfoByWindow( nativeWindow );

			if ( o == null )
				return;

			nativeWindow.removeEventListener( Event.CLOSE, nativeWindow_closeHandler );

			o.content.dispatchEvent( new Event( Event.CLOSE ) );
			ArrayUtils.removeValueFromArray( popUpInfo, o );
			removeHandlers( nativeWindow );

			if ( !nativeWindow.closed )
				nativeWindow.close();

			if ( o.parent == null )
				return;

			var parentNativeWindow : NativeWindow = o.parent.stage.nativeWindow;
			var isLockedWindow : Boolean = windowIsLocked( parentNativeWindow );

			if ( !isLockedWindow )
			{
				if ( o.parent.parentApplication != null )
					o.parent.parentApplication.enabled = true;
				else
					o.parent.enabled = true;
			}
		}

		private function addHandlers( nativeWindow : NativeWindow, handlers : Array ) : void
		{
			handlerDictionary[ nativeWindow ] = handlers;

			handlers.forEach( function( element : *, index : int, arr : Array ) : void
				{
					nativeWindow.addEventListener( element[ "type" ], element[ "handler" ] );
				} )
		}

		private function removeHandlers( nativeWindow : NativeWindow ) : void
		{
			var handlers : Array = handlerDictionary[ nativeWindow ];
			if ( handlers == null )
				return;

			handlers.forEach( function( element : *, index : int, arr : Array ) : void
				{
					nativeWindow.removeEventListener( element[ "type" ], element[ "handler" ] );
				} )
		}

		private function nativeWindow_activateHandler( event : Event ) : void
		{
			var currentNativeWindow : NativeWindow = event.currentTarget as NativeWindow;

			if ( currentNativeWindow && currentNativeWindow == lastActiveWindow )
				return;

			var ppuwd : PopUpWindowData = findFirstModalPopupInfoByParentWindow( currentNativeWindow );
			var isModal : Boolean = false;

			if ( ppuwd && ppuwd.isModal && lastActiveWindow && !lastActiveWindow.closed )
			{
				lastActiveWindow.activate();
				currentNativeWindow.orderInBackOf( ppuwd.nativeWindow );
				isModal = true;
			}

			var cpuwd : PopUpWindowData = findPopupInfoByWindow( currentNativeWindow );

			if ( cpuwd == null )
				return;

			if ( isModal )
			{
				ArrayUtils.removeValueFromArray( popUpInfo, cpuwd );
				var pi : int = popUpInfo.indexOf( ppuwd );
				var arr1 : Array = popUpInfo.slice( 0, pi );
				var arr2 : Array = popUpInfo.slice( pi );
				popUpInfo = arr1.concat( cpuwd, arr2 );
			}
			else
			{
				ArrayUtils.removeValueFromArray( popUpInfo, cpuwd );
				popUpInfo.push( cpuwd );
				lastActiveWindow = currentNativeWindow;
			}
		}

		private function nativeWindow_displayStateChangingHandler( event : NativeWindowDisplayStateEvent ) : void
		{
			if ( !popUpInfo || popUpInfo.length == 0 )
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

			var nativeWindow : NativeWindow = FlexGlobals.topLevelApplication.nativeWindow;

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

			var puwd : PopUpWindowData = findPopupInfoByWindow( nativeWindow );

			if ( !puwd )
				return;

			fitToContent( window, puwd.content );
			centerPopUp( window );

			var handlers : Array = [ { type : Event.CLOSE, handler : nativeWindow_closeHandler },
									 { type : Event.ACTIVATE, handler : nativeWindow_activateHandler } ];

			addHandlers( nativeWindow, handlers );

			if ( puwd.parent == null )
			{
				window.visible = true;
				nativeWindow.activate();
				return;
			}

			var parentNativeWindow : NativeWindow = puwd.parent.stage.nativeWindow;
			var isLockedWindow : Boolean = windowIsLocked( puwd.parent.stage.nativeWindow );
			var parentHandlers : Array;

			if ( isLockedWindow && puwd.isModal )
			{
				parentHandlers = [ { type : NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, handler : nativeWindow_displayStateChangingHandler },
								   { type : Event.CLOSING, handler : parent_closingHandler },
								   { type : Event.ACTIVATE, handler : nativeWindow_activateHandler } ];

				addHandlers( parentNativeWindow, parentHandlers );

				if ( puwd.parent.parentApplication )
					puwd.parent.parentApplication.enabled = false;
				else
					puwd.parent.enabled = false;
			}

			if ( handlerDictionary[ parentNativeWindow ] === undefined )
			{
				parentNativeWindow.addEventListener( Event.ACTIVATE, nativeWindow_activateHandler );
				handlerDictionary[ parentNativeWindow ] = [ { type : Event.ACTIVATE, handler : nativeWindow_activateHandler } ];
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
	import mx.core.UIComponent;
	

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: PopUpWindowData
//
////////////////////////////////////////////////////////////////////////////////

/**
 *  @private
 */
class PopUpWindowData
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function PopUpWindowData()
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

import flash.utils.Dictionary;