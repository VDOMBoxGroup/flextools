package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
			switch ( target )
			{
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, body );
					
					break;
				}
			}
		}
	}
}