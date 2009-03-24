package net.vdombox.ide.view
{
	import net.vdombox.ide.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import vdom.components.loginForm.LoginForm;
	import vdom.events.LoginFormEvent;

	public class LoginFormMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginFormMediator";

		public function LoginFormMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );

			init();
		}

		override public function listNotificationInterests() : Array
		{
			return [ ApplicationFacade.STARTUP ];
		}

		private function get loginForm() : LoginForm
		{
			return viewComponent as LoginForm;
		}

		private function init() : void
		{
			addEventListeners();
		}

		private function addEventListeners() : void
		{
			loginForm.addEventListener( LoginFormEvent.SUBMIT_BEGIN, submitBeginHandler );
		}
		
		private function submitBeginHandler( event : LoginFormEvent ) : void
		{
			sendNotification( ApplicationFacade.SUBMIT_BEGIN );
		}
	}
}