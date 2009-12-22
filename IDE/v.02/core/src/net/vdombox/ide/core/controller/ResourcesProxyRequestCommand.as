package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
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
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			if ( message.getTarget() == PPMResourcesTargetNames.RESOURCES )
				processResourcesTarget( message );
			else
				processResourceTarget( message );
		}

		private function processResourcesTarget( message : ProxiesPipeMessage ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var body : Object = message.getBody();
			var applicationVO : ApplicationVO;
			
			switch ( message.getOperation() )
			{
				case PPMOperationNames.READ:
				{
					applicationVO = body as ApplicationVO;
					resourcesProxy.getListResources( applicationVO );

					break;
				}
				
				case PPMOperationNames.CREATE:
				{
					var resources : Array = body as Array;
					
					resourcesProxy.setResources( resources );
					
					break;
				}
			}
		}

		private function processResourceTarget( message : ProxiesPipeMessage ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			var body : Object = message.getBody();

			var resourceVO : ResourceVO;

			switch ( message.getOperation() )
			{
				case PPMOperationNames.READ:
				{
					resourcesProxy.loadResource( resourceVO );
					
					body[ "resourceVO" ] = resourceVO;

					message.setBody( body );

					sendNotification( ApplicationFacade.RESOURCES_PROXY_RESPONSE, message );

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