package net.vdombox.ide.modules.tree.controller.messages
{
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
			switch ( target )
			{
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					sendNotification( ApplicationFacade.SELECTED_APPLICATION_GETTED, body );
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					sendNotification( ApplicationFacade.SELECTED_PAGE_GETTED, body );
					
					break;
				}
			}
		}
	}
}