package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
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
				case PPMObjectTargetNames.SERVER_ACTIONS:
				{
					if( operation == PPMOperationNames.READ )
						sendNotification( Notifications.SERVER_ACTIONS_GETTED, body );
					else if( operation == PPMOperationNames.UPDATE )
						sendNotification( Notifications.SERVER_ACTIONS_SETTED, body );
					
					break;
				}
					
				case PPMObjectTargetNames.ALL_SERVER_ACTIONS:
				{
					if( operation == PPMOperationNames.READ )
						sendNotification( Notifications.ALL_SERVER_ACTIONS_GETTED, body );
					
					break;
				}
					
				case PPMObjectTargetNames.SERVER_ACTION:
				{
					if( operation == PPMOperationNames.READ )
					{
						if ( body.check )
							sendNotification( Notifications.SCRIPT_CHECKED, body.serverActionVO );
						else
							sendNotification( Notifications.SERVER_ACTION_GETTED, body.serverActionVO );
					}
					else
					{
						if( operation == PPMOperationNames.CREATE )
							sendNotification( Notifications.SERVER_ACTION_CREATED, body );
						else if( operation == PPMOperationNames.DELETE )
							sendNotification( Notifications.SERVER_ACTION_DELETED, body );
						else if( operation == PPMOperationNames.RENAME )
								sendNotification( Notifications.SERVER_ACTION_RENAMED, body );
						
						sendNotification( Notifications.GET_SERVER_ACTIONS, body.objectVO );
					}
											
					break;
				}
					
				case PPMObjectTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( Notifications.OBJECT_DELETED, body.objectVO );
					}
					
					break;
				}
			}
		}
	}
}