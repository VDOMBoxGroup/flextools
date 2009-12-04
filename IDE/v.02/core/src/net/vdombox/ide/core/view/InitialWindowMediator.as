package net.vdombox.ide.core.view
{
	import flash.events.MouseEvent;
	
	import mx.controls.ComboBox;
	import mx.core.INavigatorContent;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
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

		public static const PROGRESS_VIEW_NAME : String = "progressView";

		public static const LOGIN_VIEW_NAME : String = "loginView";

		public static const ERROR_VIEW_NAME : String = "errorView";

		public function InitialWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var windowManager : WindowManager = WindowManager.getInstance();

		private var localeProxy : LocalesProxy;

		private var sharedObjectProxy : SharedObjectProxy;

		private var proposedViewName : String;
		
		private var _selectedViewName : String = "";
		
		private var userData : Object;
		
		public function get selectedViewName() : String
		{
			return proposedViewName != "" ? proposedViewName : _selectedViewName;
		}

		public function set selectedViewName( value : String ) : void
		{
			if( value == _selectedViewName || value == proposedViewName )
				return;
			
			proposedViewName = value;

			commitProperties();
		}
		
		public function get username() : String
		{
			return userData.username;
		}
		
		public function get password() : String
		{
			return userData.password;
		}
		
		public function get hostname() : String
		{
			return userData.hostname;
		}
		
		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;

			userData = {};
			selectedViewName = PROGRESS_VIEW_NAME;

			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.CHANGE_LOCALE );
			interests.push( ApplicationFacade.MODULES_LOADED );
			interests.push( ApplicationFacade.LOGGED_ON );
			interests.push( ApplicationFacade.CONNECTION_SERVER_SUCCESSFUL );
			interests.push( ApplicationFacade.LOGON_SUCCESS );
			interests.push( ApplicationFacade.APPLICATIONS_LOADED );
			
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.MODULES_LOADED:
				{
					selectedViewName = LOGIN_VIEW_NAME;
					
					break;
				}
					
				case ApplicationFacade.CHANGE_LOCALE:
				{
					localeProxy.changeLocale( notification.getBody() as LocaleVO );
					
					break;
				}
					
				case ApplicationFacade.PROCESS_USER_INPUT:
				{
					userData = notification.getBody();
					
					var progressViewMediator : ProgressViewMediator = facade.retrieveMediator( ProgressViewMediator.NAME ) as ProgressViewMediator;
					
					progressViewMediator.cleanup();
					selectedViewName = PROGRESS_VIEW_NAME;
					
					sendNotification( ApplicationFacade.CONNECT_SERVER );
					
					break;
				}
			}
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

		private function get initialWindow() : InitialWindow
		{
			return viewComponent as InitialWindow;
		}

		private function addEventListeners() : void
		{
			initialWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );

			initialWindow.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
		}
		
		private function commitProperties() : void
		{	
			if( proposedViewName != "" )
			{
				if ( !initialWindow.viewStack )
					return;
				
				var newValue : String = proposedViewName;
				proposedViewName = "";
				
				if ( newValue != PROGRESS_VIEW_NAME && 
					 newValue != LOGIN_VIEW_NAME && 
					 newValue != ERROR_VIEW_NAME )
				{
					return;
				}
				
				var view : INavigatorContent = initialWindow.viewStack.getChildByName( newValue ) as INavigatorContent;
				
				if ( view )
				{
					initialWindow.viewStack.selectedChild = view;
					_selectedViewName = newValue;
				}
			}
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new ProgressViewMediator( initialWindow.progressView ) );
			facade.registerMediator( new LoginViewMediator( initialWindow.loginView ) );
			facade.registerMediator( new ErrorViewMediator( initialWindow.errorView ) );
			
			commitProperties();
			sendNotification( ApplicationFacade.INITIAL_WINDOW_OPENED );
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( event.target is Button || event.target is RichEditableText || event.target.parent is ComboBox )
				return;

			initialWindow.nativeWindow.startMove();

			event.stopImmediatePropagation();
		}
	}
}