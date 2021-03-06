//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.events.Event;

	import mx.events.AIREvent;
	import mx.events.FlexEvent;

	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.InitialWindowEvent;
	import net.vdombox.ide.common.model.LogProxy;
	import net.vdombox.ide.core.model.SessionProxy;
	import net.vdombox.ide.core.view.components.InitialWindow;
	import net.vdombox.utils.VersionUtils;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class InitialWindowMediator extends Mediator implements IMediator
	{
		public static const ERROR_VIEW_STATE_NAME : String = "errorView";

		public static const LOGIN_VIEW_STATE_NAME : String = "loginView";

		public static const NAME : String = "LoginFormMediator";

		public static const PROGRESS_VIEW_STATE_NAME : String = "progressView";

		private var sessionProxy : SessionProxy;

		private var windowManager : WindowManager;

		public function InitialWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		public function get initialWindow() : InitialWindow
		{
			return viewComponent as InitialWindow;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			windowManager = WindowManager.getInstance();

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.MODULES_LOADING_SUCCESSFUL );

			interests.push( ApplicationFacade.SHOW_LOGIN_VIEW_REQUEST );

			interests.push( ApplicationFacade.REQUEST_FOR_SIGNUP );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.MODULES_LOADING_SUCCESSFUL:
				{
					initialWindow.currentState = sessionProxy.errorVO ? ERROR_VIEW_STATE_NAME : LOGIN_VIEW_STATE_NAME;

					break;
				}

				case ApplicationFacade.REQUEST_FOR_SIGNUP:
				{
					initialWindow.currentState = PROGRESS_VIEW_STATE_NAME;

					break;
				}

				case ApplicationFacade.SHOW_LOGIN_VIEW_REQUEST:
				{
					initialWindow.currentState = LOGIN_VIEW_STATE_NAME;

					break;
				}
			}

			initialWindow.validateNow();
		}

		private function addHandlers() : void
		{
			initialWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );

			initialWindow.addEventListener( AIREvent.WINDOW_COMPLETE, windowCompleteHandler, false, 0, true );

			initialWindow.addEventListener( InitialWindowEvent.EXIT, exitHandler, false, 0, true );

			initialWindow.addEventListener( InitialWindowEvent.CANCEL, cancelHandler, false, 0, true );

			initialWindow.addEventListener( InitialWindowEvent.SUBMIT, submitHandler, false, 0, true );

			initialWindow.addEventListener( Event.CLOSE, closeHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			initialWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );

			initialWindow.removeEventListener( AIREvent.WINDOW_COMPLETE, windowCompleteHandler );

			initialWindow.removeEventListener( InitialWindowEvent.EXIT, exitHandler );

			initialWindow.removeEventListener( InitialWindowEvent.SUBMIT, submitHandler );

			initialWindow.removeEventListener( Event.CLOSE, closeHandler );
		}

		public function openViewState( viewStateName : String ) : void
		{
			initialWindow.currentState = viewStateName;
		}

		public function openWindow() : void
		{
			windowManager.addWindow( initialWindow );
			initialWindow.activate();
		}

		public function closeWindow() : void
		{
			windowManager.removeWindow( initialWindow );
		}

		private function closeHandler( event : Event ) : void
		{
			removeHandlers();

			sendNotification( ApplicationFacade.CLOSE_IDE );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.INITIAL_WINDOW_CREATED, initialWindow );
			initTitle();
		}

		private function exitHandler( event : InitialWindowEvent ) : void
		{
			removeHandlers();

			sendNotification( ApplicationFacade.CLOSE_IDE );
		}

		private function cancelHandler( event : InitialWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.DISCONNECT_TO_SERVER );

			sendNotification( ApplicationFacade.SHOW_LOGIN_VIEW_REQUEST );

			sendNotification( ApplicationFacade.BACK_TO_INITIAL_WINDOW );
		}

		private function initTitle() : void
		{
			initialWindow.title = VersionUtils.getApplicationName();
		}

		private function submitHandler( event : InitialWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.SUBMIN_CLICK );
		}

		private function windowCompleteHandler( event : AIREvent ) : void
		{
			sendNotification( ApplicationFacade.INITIAL_WINDOW_OPENED );
		}
	}
}
