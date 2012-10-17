package net.vdombox.ide.modules.resourceBrowser.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessResourcesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var place : String = message.proxy;
			var operation : String = message.operation;
			var target : String = message.target;

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					if ( operation == PPMOperationNames.CREATE )
						sendNotification( Notifications.RESOURCE_UPLOADED, body );
					else if ( operation == PPMOperationNames.DELETE )
						sendNotification( Notifications.RESOURCE_DELETED, body );
					else if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.RESOURCE_LOADED, body );
					
					break;
				}
					
				case PPMResourcesTargetNames.RESOURCES:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.RESOURCES_GETTED, body );
					
					break;
				}
			}
		}
	}
}