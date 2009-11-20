package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ServerProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			var applications : Array = serverProxy.applications;
			var body : Object = notification.getBody();
			
			sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, 
							  { operation : body.operation, target : body.target, parameters : applications }
			);
		}
	}
}