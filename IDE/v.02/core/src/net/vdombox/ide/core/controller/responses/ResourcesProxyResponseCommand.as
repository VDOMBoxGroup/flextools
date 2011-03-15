package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.ResourceVO;
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
					resourceVO = body as ResourceVO;
					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = body as ResourceVO;
					
					if( !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyResponseCommand: RESOURCE_SETTED resourceVO is null." );
						return;
					}
					
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					break;
				}
				
				case ApplicationFacade.RESOURCE_MODIFIED:
				{
					resourceVO = body as ResourceVO;
					
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
					resourceVO = body as ResourceVO;
					
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