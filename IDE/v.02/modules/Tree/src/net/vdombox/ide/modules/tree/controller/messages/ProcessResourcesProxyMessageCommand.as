package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.controller.Notifications;
	
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
				case PPMResourcesTargetNames.RESOURCES:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( Notifications.RESOURCES_GETTED, body );
					}
					
					break;
				}
			}
		}
	}
}