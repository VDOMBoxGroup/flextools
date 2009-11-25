package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.vo.ResourceVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ResourcesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			
			var ppMessage : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var parameters : Object = ppMessage.parameters;
			var applicationID : String;
			
			if( !hasOwnProperty( parameters.applicationID ) )
			{
				applicationID = serverProxy.selectedApplication.id;
			}
			
			var resourceVO : ResourceVO = resourcesProxy.getResource( applicationID, parameters.resourceID );
			parameters.resourceVO = resourceVO;
			
			sendNotification( ApplicationFacade.RESOURCES_PROXY_RESPONSE, 
				{ operation : ppMessage.operation, target : ppMessage.target, parameters : parameters }
			);
		}
	}
}