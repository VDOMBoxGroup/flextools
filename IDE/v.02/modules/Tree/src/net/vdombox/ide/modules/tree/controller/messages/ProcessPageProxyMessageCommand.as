package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.view.TreeElementMediator;

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
					var pageAttributesVO : PageAttributesVO = body.pageAttributesVO as PageAttributesVO;

					var allPageRecipients : Object = sessionProxy.getObject( place + ApplicationFacade.DELIMITER + operation +
						ApplicationFacade.DELIMITER + target );

					var pageRecipient : Array = allPageRecipients[ pageAttributesVO.pageVO.id ];
					var recipientID : String;

					if ( operation == PPMOperationNames.READ )
					{
						for each ( recipientID in pageRecipient )
						{
							sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + recipientID, pageAttributesVO );
						}
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						for each ( recipientID in pageRecipient )
						{
							sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + recipientID, pageAttributesVO );
						}
						
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_SETTED, pageAttributesVO );
					}

					delete allPageRecipients[ pageAttributesVO.pageVO.id ];

					break;
				}
			}
		}
	}
}