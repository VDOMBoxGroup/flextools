package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.TypesProxy;
	import net.vdombox.ide.core.view.InitialWindowMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectionServerSuccessfulCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new TypesProxy() );
			facade.registerProxy( new ResourcesProxy() );
			
			var initialWindowMediator : InitialWindowMediator = facade.retrieveMediator( InitialWindowMediator.NAME ) as InitialWindowMediator;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			serverProxy.logon( initialWindowMediator.username, initialWindowMediator.password );
		}
	}
}