package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMPageTargetNames.ATTRIBUTES:
				{
					var vdomObjectAttributesVO : VdomObjectAttributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;

					var allPageRecipients : Object = sessionProxy.getObject( place + ApplicationFacade.DELIMITER + operation +
						ApplicationFacade.DELIMITER + target );

					var pageRecipient : Array = allPageRecipients[ vdomObjectAttributesVO.vdomObjectVO.id ];
					var recipientID : String;

					if ( operation == PPMOperationNames.READ )
					{
						for each ( recipientID in pageRecipient )
						{
							sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + recipientID, vdomObjectAttributesVO );
						}
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						for each ( recipientID in pageRecipient )
						{
							sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + recipientID, vdomObjectAttributesVO );
						}
						
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_SETTED, vdomObjectAttributesVO );
					}

					delete allPageRecipients[ vdomObjectAttributesVO.vdomObjectVO.id ];

					break;
				}
					
				case PPMPageTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.PAGE_NAME_SETTED, body );
					}
					break;
				}
			}
		}
	}
}