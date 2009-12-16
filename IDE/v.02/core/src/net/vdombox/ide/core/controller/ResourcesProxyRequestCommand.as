package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
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

			var body : Object = ppMessage.getBody();
			var ownerID : String;

			var resourceVO : ResourceVO;
			
			switch ( ppMessage.getOperation())
			{
				case PPMOperationNames.READ:
				{
					if ( !body.hasOwnProperty( "ownerID" ))
					{
						ownerID = serverProxy.selectedApplication.id;
					}

					resourceVO = resourcesProxy.getResource( ownerID, body.resourceID );
					body[ "resourceVO" ] = resourceVO;

					ppMessage.setBody( body );

					sendNotification( ApplicationFacade.RESOURCES_PROXY_RESPONSE, ppMessage );

					break;
				}

				case PPMOperationNames.CREATE:
				{
					resourceVO = body as ResourceVO;

					if ( !resourceVO || !resourceVO.data )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyRequestCommand: Set resource error." );
						return;
					}

					resourcesProxy.setResource( resourceVO );

					break;
				}
			}
		}
	}
}