package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
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
					
				case PPMPageTargetNames.STRUCTURE:
				{
					sendNotification( Notifications.STRUCTURE_GETTED, body );
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					if(  operation == PPMOperationNames.READ )
						sendNotification( Notifications.SERVER_ACTIONS_GETTED, body );
					else if( operation == PPMOperationNames.UPDATE )
						sendNotification( Notifications.SERVER_ACTIONS_SETTED, body.serverActions );
					
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTION:
				{
					if( operation == PPMOperationNames.CREATE )
						sendNotification( Notifications.SERVER_ACTION_CREATED, body );
					else if( operation == PPMOperationNames.DELETE )
						sendNotification( Notifications.SERVER_ACTION_DELETED, body );
					else
					{
						if( operation == PPMOperationNames.RENAME )
							sendNotification( Notifications.SERVER_ACTION_RENAMED, body );
						
						var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
					
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedPage );
					}
					
					break;
				}	
			}
		}
	}
}