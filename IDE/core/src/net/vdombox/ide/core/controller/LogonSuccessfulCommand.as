package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.TypesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LogonSuccessfulCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;

			serverProxy.loadApplications();
			typesProxy.loadTypes();
		}
	}
}
