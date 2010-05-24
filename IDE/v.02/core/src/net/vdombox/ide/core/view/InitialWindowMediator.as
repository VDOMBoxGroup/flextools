package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	import flash.events.MouseEvent;

	import mx.controls.ComboBox;
	import mx.core.INavigatorContent;
	import mx.events.AIREvent;
	import mx.events.FlexEvent;

	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.InitialWindowEvent;
	import net.vdombox.ide.core.model.LocalesProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.model.vo.LocaleVO;
	import net.vdombox.ide.core.view.components.InitialWindow;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.components.Button;
	import spark.components.RichEditableText;

	public class InitialWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginFormMediator";

		private static const PROGRESS_VIEW_STATE_NAME : String = "progressView";
		private static const LOGIN_VIEW_STATE_NAME : String = "loginView";
		private static const ERROR_VIEW_STATE_NAME : String = "errorView";

		public function InitialWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var windowManager : WindowManager = WindowManager.getInstance();

//		private var localeProxy : LocalesProxy;
//
//		private var sharedObjectProxy : SharedObjectProxy;
//
//		private var proposedViewName : String;
//
//		private var _selectedViewName : String = "";
//
//		private var userData : Object;

		public function get initialWindow() : InitialWindow
		{
			return viewComponent as InitialWindow;
		}

//		public function get selectedViewName() : String
//		{
//			return proposedViewName != "" ? proposedViewName : _selectedViewName;
//		}
//
//		public function set selectedViewName( value : String ) : void
//		{
//			if( value == _selectedViewName || value == proposedViewName )
//				return;
//			
//			proposedViewName = value;
//
//			commitProperties();
//		}
//		
//		public function get username() : String
//		{
//			return userData.username;
//		}
//		
//		public function get password() : String
//		{
//			return userData.password;
//		}
//		
//		public function get hostname() : String
//		{
//			return userData.hostname;
//		}

		override public function onRegister() : void
		{
//			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
//			localeProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;
//
//			userData = {};

			addHandlers();
		}

		override public function onRemove() : void
		{
//			sharedObjectProxy = null;
//			localeProxy = null;
//
//			userData = {};

			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.MODULES_LOADED );

			interests.push( ApplicationFacade.REQUEST_FOR_SIGNUP );
			
			
//			interests.push( ApplicationFacade.TYPES_LOADED );
//			interests.push( ApplicationFacade.LOGON_ERROR );
//			interests.push( ApplicationFacade.SHOW_LOGON_VIEW );
//			interests.push( ApplicationFacade.SHOW_ERROR_VIEW );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.MODULES_LOADED:
				{
					initialWindow.currentState = LOGIN_VIEW_STATE_NAME;
					initialWindow.validateNow();
					
					break;
				}
					
				case ApplicationFacade.REQUEST_FOR_SIGNUP:
				{
					initialWindow.currentState = PROGRESS_VIEW_STATE_NAME
					initialWindow.validateNow();
					
					break;
				}
			}
		}

				
//					
//				case ApplicationFacade.LOGON_ERROR:
//				{
//					selectedViewName = ERROR_VIEW_NAME;
//					
//					break;
//				}
//					
//				case ApplicationFacade.SHOW_LOGON_VIEW:
//				{
//					selectedViewName = LOGIN_VIEW_NAME;
//					
//					break;
//				}
//					
//				case ApplicationFacade.SHOW_ERROR_VIEW:
//				{
//					selectedViewName = ERROR_VIEW_NAME;
//					
//					errorViewMediator.errorText = notification.getBody().toString();
//					
//					break;
//				}
//			}
//		}

		public function openWindow() : void
		{
			windowManager.addWindow( initialWindow );
			initialWindow.activate();
		}

		public function closeWindow() : void
		{
			windowManager.removeWindow( initialWindow );
		}

		private function addHandlers() : void
		{
			initialWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );
			initialWindow.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true );

			initialWindow.addEventListener( AIREvent.WINDOW_COMPLETE, windowCompleteHandler, false, 0, true );

			initialWindow.addEventListener( InitialWindowEvent.EXIT, exitHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			initialWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			initialWindow.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );

			initialWindow.removeEventListener( AIREvent.WINDOW_COMPLETE, windowCompleteHandler );

			initialWindow.removeEventListener( InitialWindowEvent.EXIT, exitHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.INITIAL_WINDOW_CREATED, initialWindow );

			if ( initialWindow.currentState != PROGRESS_VIEW_STATE_NAME )
				initialWindow.currentState = PROGRESS_VIEW_STATE_NAME;
		}

		private function windowCompleteHandler( event : AIREvent ) : void
		{
			sendNotification( ApplicationFacade.INITIAL_WINDOW_OPENED );
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( event.target is Button || event.target is RichEditableText || event.target.parent is ComboBox )
				return;

			initialWindow.nativeWindow.startMove();

			event.stopImmediatePropagation();
		}

		private function exitHandler( event : InitialWindowEvent ) : void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
}