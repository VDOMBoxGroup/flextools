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
					if( PPMOperationNames.READ )
						sendNotification( Notifications.SERVER_ACTIONS_GETTED, body );
					else if( PPMOperationNames.UPDATE )
						sendNotification( Notifications.SERVER_ACTIONS_SETTED, body.serverActions );
					
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTION:
				{
					var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
					
					sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedPage );
					
					break;
				}	
			}
		}
	}
}