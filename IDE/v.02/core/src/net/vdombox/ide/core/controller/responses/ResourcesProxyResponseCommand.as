package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DB_T4EomEeC-JfVEe_-0Aw
	 */
	public class ResourcesProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var message : ProxyMessage;
			
			var resourceVO : ResourceVO;
			if ( body is ResourceVO )
				resourceVO = body as ResourceVO;;
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.RESOURCES_GETTED:
				{
					var resources : Array = body as Array;
					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, 
						PPMResourcesTargetNames.RESOURCES, resources );
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_LOADED:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.ICON_GETTED:
				{					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, 
						PPMResourcesTargetNames.ICON, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{					
					if( !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyResponseCommand: RESOURCE_SETTED resourceVO is null." );
						return;
					}
					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED_ERROR:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
				
				case ApplicationFacade.RESOURCE_MODIFIED:
				{
					if( !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyResponseCommand: RESOURCE_UPDATE resourceVO is null." );
						return;
					}
					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.UPDATE, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_DELETED:
				{					
					if( !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyResponseCommand: RESOURCE_DELETED resourceVO is null." );
						return;
					}
					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.DELETE, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
			}
			
			sendNotification( ApplicationFacade.RESOURCES_PROXY_RESPONSE, message );
		}
	}
}