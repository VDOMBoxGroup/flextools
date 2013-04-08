package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.TypesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 *
	 * @author adelfos
	 *
	 * Server Login Successful Command
	 * body is AuthInfoVO
	 * as next step it start loading VDOM Types
	 *
	 */
	public class ServerLoginSuccessfulCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			typesProxy.loadTypes();

			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			serverProxy.loadApplications();
		}
	}
}
