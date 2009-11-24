package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ResourcesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ResourcesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var resourceVO : resourceVO = resourcesProxy.getResource( notification.getBody().iconID );
			
			sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, 
				{ operation : body.operation, target : body.target, parameters : applications }
			);
		}
	}
}