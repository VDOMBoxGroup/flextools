package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessResourcesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var operation : String = message.operation;
			var target : String = message.target;

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						if ( sessionProxy.selectedObject )
						{
//							sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, sessionProxy.selectedObject );
//							sendNotification( ApplicationFacade.GET_OBJECT_WYSIWYG, sessionProxy.selectedObject );
						}
					}
					else if ( operation == PPMOperationNames.READ )
					{
//						var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
//						resourcesProxy.resourceGeted( body as ResourceVO);
					}
					else if ( operation == PPMOperationNames.CREATE )
						sendNotification( ApplicationFacade.RESOURCE_SETTED, body );
					
					break;
				}
					
				case PPMResourcesTargetNames.RESOURCES:
				{					
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.RESOURCES_GETTED, body );

					break;
				}
				
				case PPMResourcesTargetNames.ICON:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.ICON_GETTED, body );	
					
					break;
				}
			}
		}
	}
}