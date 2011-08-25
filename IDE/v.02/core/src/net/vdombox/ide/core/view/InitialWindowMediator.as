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
	import net.vdombox.ide.core.model.SessionProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.model.vo.LocaleVO;
	import net.vdombox.ide.core.view.components.InitialWindow;
	import net.vdombox.utils.VersionUtils;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Button;
	import spark.components.RichEditableText;

	public class InitialWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginFormMediator";

		public static const PROGRESS_VIEW_STATE_NAME : String = "progressView";
		public static const LOGIN_VIEW_STATE_NAME : String = "loginView";
		public static const ERROR_VIEW_STATE_NAME : String = "errorView";

		public function InitialWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var windowManager : WindowManager = WindowManager.getInstance();
		
		private var sessionProxy : SessionProxy;

		public function get initialWindow() : InitialWindow
		{
			return viewComponent as InitialWindow;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
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
					if( sessionProxy.errorVO )
						initialWindow.currentState = ERROR_VIEW_STATE_NAME;
					else
						initialWindow.currentState = LOGIN_VIEW_STATE_NAME;
					
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
		
		public function openWindow() : void
		{
			windowManager.addWindow( initialWindow );
			initialWindow.activate();
		}

		public function closeWindow() : void
		{
			windowManager.removeWindow( initialWindow );
		}

		public function openViewState( viewStateName : String ) : void
		{
			initialWindow.currentState = viewStateName;
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
			initTitle();
		}
		
		private function initTitle():void
		{
			initialWindow.title = VersionUtils.getApplicationName();
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