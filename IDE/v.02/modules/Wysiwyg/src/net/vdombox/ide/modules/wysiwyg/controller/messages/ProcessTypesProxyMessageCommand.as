package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var place : String = message.getPlace();
			var operation : String = message.getOperation();
			var target : String = message.getTarget();

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					if( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.TYPES_GETTED, message.getBody() );
					
					break;
				}
				case PPMTypesTargetNames.TYPE:
				{
					if( operation != PPMOperationNames.READ )
						break;
					
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
			}
		}
	}
}