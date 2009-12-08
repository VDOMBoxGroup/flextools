package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ResourcesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			
			var ppMessage : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var parameters : Object = ppMessage.getParameters();
			var ownerID : String;
			
			if( !parameters.hasOwnProperty( "ownerID" ) )
			{
				ownerID = serverProxy.selectedApplication.id;
			}
			
			var resourceVO : ResourceVO = resourcesProxy.getResource( ownerID, parameters.resourceID );
			parameters["resourceVO"] = resourceVO;
			
			ppMessage.setParameters( parameters );
			
			sendNotification( ApplicationFacade.RESOURCES_PROXY_RESPONSE, ppMessage );
		}
	}
}