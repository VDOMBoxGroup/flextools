package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
//			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			switch ( target )
			{
				case PPMPageTargetNames.OBJECTS:
				{
					var pageAttributesVO : PageAttributesVO = body as PageAttributesVO;

					break;
				}
					
				case PPMPageTargetNames.STRUCTURE:
				{
					sendNotification( ApplicationFacade.STRUCTURE_GETTED, body );
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					sendNotification( ApplicationFacade.SERVER_ACTIONS_GETTED, body );
					
					break;
				}
			}
		}
	}
}