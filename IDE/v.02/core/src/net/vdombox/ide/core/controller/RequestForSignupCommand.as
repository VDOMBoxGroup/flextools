package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	import net.vdombox.ide.core.view.InitialWindowMediator;
	import net.vdombox.ide.core.view.LoginViewMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RequestForSignupCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var loginViewMediator : LoginViewMediator = facade.retrieveMediator( LoginViewMediator.NAME ) as LoginViewMediator;
			var sharedObjectProxy : SharedObjectProxy = facade.retrieveProxy( SharedObjectProxy.NAME ) as SharedObjectProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			sharedObjectProxy.username = loginViewMediator.username;
			sharedObjectProxy.password = loginViewMediator.password;
			sharedObjectProxy.hostname = loginViewMediator.hostname;
			
			serverProxy.connect();
		}
	}
}