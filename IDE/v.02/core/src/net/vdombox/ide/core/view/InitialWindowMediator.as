package net.vdombox.ide.core.view
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.ComboBox;
	import mx.core.INavigatorContent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.LocaleProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.view.components.InitialWindow;
	import net.vdombox.ide.core.view.components.initialWindowClasses.ErrorView;
	import net.vdombox.ide.core.view.components.initialWindowClasses.LoginView;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
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

		private var localeProxy : LocaleProxy;

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
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			selectedViewName = PROGRESS_VIEW_NAME;

			addEventListeners();
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
				
				var view : INavigatorContent = initialWindow.getChildByName( newValue ) as INavigatorContent;
				
				if ( view )
				{
					initialWindow.viewStack.selectedChild = view;
					selectedViewName = newValue;
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