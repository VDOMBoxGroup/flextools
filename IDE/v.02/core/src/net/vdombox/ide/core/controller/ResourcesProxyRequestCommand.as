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

		private function processResourceTarget( message : ProxiesPipeMessage ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			var body : Object = message.getBody();
			
			var resourceVO : ResourceVO;
			
			if ( body is ResourceVO )
				resourceVO = body as ResourceVO;
			else if ( body.hasOwnProperty( "resourceVO" ) )
				resourceVO = body.resourceVO as ResourceVO;
			else
				throw new Error( "no page VO" );
			
			switch ( message.getOperation() )
			{
				case PPMOperationNames.READ:
				{	
					resourceVO = body as ResourceVO;
					
					resourcesProxy.loadResource( resourceVO );
					
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
					
				case PPMOperationNames.DELETE:
				{
					resourceVO = body.resourceVO as ResourceVO;
					var applicationVO : ApplicationVO = body.applicationVO;
					
					if ( !applicationVO && !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyRequestCommand: Delete resource error." );
						return;
					}
					
					resourcesProxy.deleteResource( applicationVO, resourceVO );
					
					break;
				}
			}
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
	}
}