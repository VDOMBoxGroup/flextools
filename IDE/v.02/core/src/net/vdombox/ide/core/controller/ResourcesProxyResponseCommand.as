package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ResourcesProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var message : ProxiesPipeMessage;
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.RESOURCE_SETTED:
				{
					var resourceVO : ResourceVO = body as ResourceVO;
					
					if( !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyResponseCommand: RESOURCE_SETTED resourceVO is null." );
						return;
					}
					
					message = new ProxiesPipeMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE, 
						PPMResourcesTargetNames.RESOURCE, resourceVO );
					
					sendNotification( ApplicationFacade.RESOURCES_PROXY_RESPONSE, message );
					
					break;
				}
			}
		}
	}
}