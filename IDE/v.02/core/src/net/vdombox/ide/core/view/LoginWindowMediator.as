package net.vdombox.ide.core.view
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.ComboBox;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.LocaleProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.view.components.LoginWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Button;
	import spark.components.RichEditableText;
	
	public class LoginWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginFormMediator";

		public function LoginWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		private var localeProxy : LocaleProxy;

		private var sharedObjectProxy : SharedObjectProxy;

		override public function listNotificationInterests() : Array
		{
			return [ ApplicationFacade.STARTUP ];
		}

		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			addEventListeners();
		}

		private function addEventListeners() : void
		{
			loginWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			loginWindow.addEventListener( FlexEvent.SHOW, showHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			loginWindow.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			loginWindow.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );

			loginWindow.selectLang.addEventListener( ListEvent.CHANGE, selectLang_changeHandler );
			loginWindow.submitButton.addEventListener( MouseEvent.CLICK, submitButton_clickHandler );
			loginWindow.quitButton.addEventListener( MouseEvent.CLICK, quitButton_clickHandler );

			loginWindow.username.text = sharedObjectProxy.username;
			loginWindow.hostname.text = sharedObjectProxy.hostname;
			loginWindow.selectLang.dataProvider = localeProxy.languageList;
		}

		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == 13 )
				submit();
		}

		private function get loginWindow() : LoginWindow
		{
			return viewComponent as LoginWindow;
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( event.target is Button || event.target is RichEditableText || event.target.parent is ComboBox )
				return;

			loginWindow.nativeWindow.startMove();

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
			loginFormData.username = loginWindow.username.text;
			loginFormData.password = loginWindow.password.text;
			loginFormData.hostname = loginWindow.hostname.text;

			sendNotification( ApplicationFacade.SUBMIT, loginFormData );
		}

		private function submitButton_clickHandler( event : MouseEvent ) : void
		{
			submit();
		}
	}
}