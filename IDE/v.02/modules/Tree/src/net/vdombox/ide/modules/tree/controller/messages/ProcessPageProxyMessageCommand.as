package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			switch ( target )
			{
				case PPMPageTargetNames.ATTRIBUTES:
				{
					var pageAttributesVO : PageAttributesVO = body as PageAttributesVO;

					var allPageRecipients : Object = sessionProxy.getObject( place + ApplicationFacade.DELIMITER + operation +
						ApplicationFacade.DELIMITER + target );

					var pageRecipient : Array = allPageRecipients[ pageAttributesVO.pageID ];

					var recipientID : String;

					for each ( recipientID in pageRecipient )
					{
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + recipientID, pageAttributesVO );
					}

					delete allPageRecipients[ pageAttributesVO.pageID ];

					break;
				}
			}
		}
	}
}