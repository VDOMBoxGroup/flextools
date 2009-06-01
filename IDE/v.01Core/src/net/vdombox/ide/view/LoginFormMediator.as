package net.vdombox.ide.view
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import mx.controls.TextInput;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.ApplicationFacade;
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.SharedObjectProxy;
	import net.vdombox.ide.view.components.LoginForm;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class LoginFormMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginFormMediator";

		public function LoginFormMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var sharedObjectProxy : SharedObjectProxy;
		private var localeProxy : LocaleProxy;

//		override public function listNotificationInterests() : Array
//		{
//			return [ ApplicationFacade.STARTUP ];
//		}

		override public function onRegister() : void
		{
			sharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			addEventListeners();
		}

		private function get loginForm() : LoginForm
		{
			return viewComponent as LoginForm;
		}

		private function addEventListeners() : void
		{
			loginForm.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			loginForm.addEventListener( FlexEvent.SHOW, showHandler );
		}

		private function submit() : void
		{
			var loginFormData : Object = {};
			loginFormData.username = loginForm.username.text;
			loginFormData.password = loginForm.password.text;
			loginFormData.hostname = loginForm.hostname.text;
			
			sendNotification( ApplicationFacade.SUBMIT_BEGIN, loginFormData );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			loginForm.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			loginForm.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );

			loginForm.selectLang.addEventListener( ListEvent.CHANGE, selectLang_changeHandler );
			loginForm.submitButton.addEventListener( MouseEvent.CLICK, submitButton_clickHandler );
			loginForm.exitButton.addEventListener( MouseEvent.CLICK, exitButton_clickHandler );

			loginForm.username.text = sharedObjectProxy.username;
			loginForm.hostname.text = sharedObjectProxy.hostname;
			loginForm.selectLang.dataProvider = localeProxy.languageList;
		}

		private function showHandler( event : FlexEvent ) : void
		{
//			loginForm.
		}

		private function mouseDownHandler( event : MouseEvent ) : void
		{
			if ( event.target is Button || event.target.parent is TextInput )
				return;

//			loginForm.stage.nativeWindow.startMove();

			event.stopImmediatePropagation();
		}

		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == 13 )
				submit();
		}

		private function selectLang_changeHandler( event : ListEvent ) : void
		{
			var selectedItem : XML = event.currentTarget.selectedItem as XML;
			localeProxy.changeLocale( selectedItem.@code );
		}

		private function submitButton_clickHandler( event : MouseEvent ) : void
		{
			submit();
		}

		private function exitButton_clickHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.QUIT );
		}
	}
}