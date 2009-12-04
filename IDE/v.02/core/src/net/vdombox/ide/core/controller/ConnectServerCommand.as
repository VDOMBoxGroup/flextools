package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.view.InitialWindowMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ConnectServerCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var initialWindowMediator : InitialWindowMediator = facade.retrieveMediator( InitialWindowMediator.NAME ) as InitialWindowMediator;
			var serverProxy : ServerProxy = facade.retrieveMediator( ServerProxy.NAME ) as ServerProxy;
			
			serverProxy.connect( initialWindowMediator.hostname );
		}
	}
}