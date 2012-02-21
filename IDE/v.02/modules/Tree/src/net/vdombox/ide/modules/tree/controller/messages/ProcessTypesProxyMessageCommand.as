package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var place : String = message.proxy;
			var operation : String = message.operation;
			var target : String = message.target;

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMTypesTargetNames.TYPE:
				{
					var typeVO : TypeVO = body as TypeVO;

					var allTypeRecipients : Object = statesProxy.getObject( place + Notifications.DELIMITER + operation +
						Notifications.DELIMITER + target );

					var typeRecipient : Array = allTypeRecipients[ typeVO.id ];

					var recipientID : String;

					for each ( recipientID in typeRecipient )
					{
						sendNotification( TypesProxy.TYPE_GETTED + Notifications.DELIMITER + recipientID, typeVO );
					}

					delete allTypeRecipients[ typeVO.id ];

					break;
				}

				case PPMTypesTargetNames.TOP_LEVEL_TYPES:
				{
					sendNotification( TypesProxy.TOP_LEVEL_TYPES_GETTED, body );

					break;
				}
			}
		}
	}
}