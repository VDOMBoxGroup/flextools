package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessApplicationProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMApplicationTargetNames.PAGES:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.DATA_BASES_GETTED, body.pages );
					
					break;
				}
					
				case PPMApplicationTargetNames.PAGE:
				{
					if ( operation == PPMOperationNames.CREATE )
						sendNotification( Notifications.PAGE_CREATED, body );
					else if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.PAGE_GETTED, body );
					
					break;
				}
					
				case PPMApplicationTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
					{
						if ( body.hasOwnProperty("result") )
							sendNotification( Notifications.REMOTE_CALL_RESPONSE, body );
						else
							sendNotification( Notifications.REMOTE_CALL_RESPONSE_ERROR, body );
					}
					
					break;
				}
			}
		}
	}
}