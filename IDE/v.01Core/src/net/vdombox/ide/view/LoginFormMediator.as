package net.vdombox.ide.view
{
	import flash.events.MouseEvent;

	import mx.events.FlexEvent;
	import mx.events.ListEvent;

	import net.vdombox.ide.ApplicationFacade;
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.LoginProxy;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import vdom.components.loginForm.LoginForm;
	import vdom.events.LoginFormEvent;

	public class LoginFormMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginFormMediator";

		public function LoginFormMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var loginProxy : LoginProxy;
		private var localeProxy : LocaleProxy;

		override public function listNotificationInterests() : Array
		{
			return [ ApplicationFacade.STARTUP ];
		}
		
		override public function onRegister():void
		{
			loginProxy = facade.retrieveProxy( LoginProxy.NAME ) as LoginProxy;
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

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			loginForm.selectLang.addEventListener( ListEvent.CHANGE, changeLanguageHandler );
			loginForm.submitButton.addEventListener( MouseEvent.CLICK, submitHandler );
			loginForm.quitButton.addEventListener( MouseEvent.CLICK, quitHandler );

			

			loginForm.username.text = loginProxy.username;
			loginForm.hostname.text = loginProxy.hostname;
			loginForm.selectLang.dataProvider = localeProxy.languageList;
		}

		private function showHandler( event : FlexEvent ) : void
		{
//			loginForm.
		}

		private function changeLanguageHandler( event : ListEvent ) : void
		{
			var selectedItem : XML = event.currentTarget.selectedItem as XML;
			localeProxy.changeLocale( selectedItem.@code );
		}

		private function submitHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.SUBMIT_BEGIN );
		}

		private function quitHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.QUIT );
		}
	}
}