package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
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
					
					break;
				}
					
				case PPMResourcesTargetNames.RESOURCES:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.RESOURCES_GETTED, body );
					}

					break;
				}
			}
		}
	}
}