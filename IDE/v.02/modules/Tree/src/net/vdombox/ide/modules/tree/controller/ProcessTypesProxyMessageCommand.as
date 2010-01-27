package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as
				SessionProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var place : String = message.getPlace();
			var operation : String = message.getOperation();
			var target : String = message.getTarget();

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMTypesTargetNames.TYPE:
				{
					var typeVO : TypeVO = body as TypeVO;

					var recipients : Array = sessionProxy.getObject( place +
						ApplicationFacade.DELIMITER + operation + ApplicationFacade.DELIMITER +
						target )[ typeVO.id ];

					var recipientID : String;

					for each ( recipientID in recipients )
					{
						sendNotification( ApplicationFacade.TYPE_GETTED +
							ApplicationFacade.DELIMITER + recipientID, typeVO );
					}

					break;
				}
			}
		}
	}
}