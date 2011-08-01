package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ResourcesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DBvcQEomEeC-JfVEe_-0Aw
	 */
	public class ResourcesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			/*if ( message.target == PPMResourcesTargetNames.RESOURCES )
				processResourcesTarget( message );
			else 
				processResourceTarget( message );*/
			
			switch ( message.target )
			{
				case PPMResourcesTargetNames.RESOURCES:
				{
					processResourcesTarget( message );
					
					break;
				}
					
				case PPMResourcesTargetNames.RESOURCE:
				{
					processResourceTarget( message );
					
					break;
				}
					
				case PPMResourcesTargetNames.ICON:
				{
					processIconTarget( message );
					
					break;
				}
			}
		}
		
		private function processIconTarget( message : ProxyMessage ) : void
		{
			trace ("[ResourcesProxyRequestCommand] processIconTarget");
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			
			var operation : String = message.operation;
			var body : Object = message.getBody();			
			var resourceVO : ResourceVO;
						
			if ( operation == PPMOperationNames.READ )
			{
				if( body is ResourceVO )
					resourceVO = body as ResourceVO;
				else if( body.hasOwnProperty( "resourceVO" ) )
					resourceVO = body.resourceVO  as ResourceVO;
				else
					throw new Error( "no page VO" );
				
				if( resourceVO )
					resourcesProxy.getIcon( resourceVO );
			}
		}

		private function processResourceTarget( message : ProxyMessage ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var target : String = message.target;
			var operation : String = message.operation;
			var body : Object = message.getBody();
			
			var resourceVO : ResourceVO;
			var applicationVO : ApplicationVO;
			
			if ( body is ResourceVO )
				resourceVO = body as ResourceVO;
			else if ( body.hasOwnProperty( "resourceVO" ) )
				resourceVO = body.resourceVO as ResourceVO;
			else
				throw new Error( "no page VO" );
			
			switch ( operation )
			{
				case PPMOperationNames.READ:
				{	
					if( body is ResourceVO )
						resourceVO = body as ResourceVO;
					else if( body.hasOwnProperty( "resourceVO" ) )
						resourceVO = body.resourceVO;
					
					if( resourceVO )
						resourcesProxy.loadResource( resourceVO ); 
					
					break;
				}
					
				case PPMOperationNames.CREATE:
				{
					if( body is ResourceVO )
						resourceVO = body as ResourceVO;
					else if( body.hasOwnProperty( "resourceVO" ) )
						resourceVO = body.resourceVO;
					
					if ( !resourceVO )
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
					applicationVO = body.applicationVO;
					
					if ( !applicationVO && !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyRequestCommand: Delete resource error." );
						return;
					}
					
					resourcesProxy.deleteResource( applicationVO, resourceVO );
					
					break;
				}
					
				case PPMOperationNames.UPDATE:
				{
					resourceVO = body.resourceVO as ResourceVO;
					applicationVO = body.applicationVO;
					
					if ( !applicationVO && !resourceVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ResourcesProxyRequestCommand: Update resource error." );
						return;
					}
					
					resourcesProxy.modifyResource( applicationVO, resourceVO, body.attributeName, body.operation, body.attributes );
					
					break;
				}
			}
		}
		
		private function processResourcesTarget( message : ProxyMessage ) : void
		{
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			var body : Object = message.getBody();
			var applicationVO : ApplicationVO;
			
			switch ( message.operation )
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