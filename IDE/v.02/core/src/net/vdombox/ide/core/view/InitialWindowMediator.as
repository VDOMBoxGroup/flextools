package net.vdombox.ide.core.view
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.ComboBox;
	import mx.core.INavigatorContent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
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

		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocalesProxy.NAME ) as LocalesProxy;

			selectedViewName = PROGRESS_VIEW_NAME;

			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.CHANGE_LOCALE );
			interests.push( ApplicationFacade.MODULES_LOADED );
			
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
			initialWindow.addEventListener( FlexEvent.SHOW, showHandler );

			initialWindow.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			initialWindow.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
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

		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == 13 )
				submit();
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( event.target is Button || event.target is RichEditableText || event.target.parent is ComboBox )
				return;

			initialWindow.nativeWindow.startMove();

			event.stopImmediatePropagation();
		}

		private function quitButton_clickHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.QUIT );
		}

		private function selectLang_changeHandler( event : ListEvent ) : void
		{
			var selectedItem : XML = event.currentTarget.selectedItem as XML;
			localeProxy.changeLocale( selectedItem.@code );
		}

		private function showHandler( event : FlexEvent ) : void
		{
//			loginForm.
		}

		private function submit() : void
		{
			var loginFormData : Object = {};
			loginFormData.username //= initialWindow.username.text;
			loginFormData.password //= initialWindow.password.text;
			loginFormData.hostname //= initialWindow.hostname.text;

			sharedObjectProxy.username //= initialWindow.username.text;
			sharedObjectProxy.hostname //= initialWindow.hostname.text;

			sendNotification( ApplicationFacade.SUBMIT, loginFormData );
		}

		private function submitButton_clickHandler( event : MouseEvent ) : void
		{
			submit();
		}
	}
}