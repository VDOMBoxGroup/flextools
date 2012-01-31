package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.model.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

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

					var allTypeRecipients : Object = sessionProxy.getObject( place + ApplicationFacade.DELIMITER + operation +
						ApplicationFacade.DELIMITER + target );

					var typeRecipient : Array = allTypeRecipients[ typeVO.id ];

					var recipientID : String;

					for each ( recipientID in typeRecipient )
					{
						sendNotification( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + recipientID, typeVO );
					}

					delete allTypeRecipients[ typeVO.id ];

					break;
				}

				case PPMTypesTargetNames.TOP_LEVEL_TYPES:
				{
					sendNotification( ApplicationFacade.TOP_LEVEL_TYPES_GETTED, body );

					break;
				}
			}
		}
	}
}