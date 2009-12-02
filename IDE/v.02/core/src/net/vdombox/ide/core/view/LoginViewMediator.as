package net.vdombox.ide.core.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class LoginViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoginView";
		
		public function LoginViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
	}
}