package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMObjectTargetNames.SERVER_ACTIONS_LIST:
				{
					sendNotification( ApplicationFacade.SERVER_ACTIONS_LIST_GETTED, body.serverActions as Array );
					
					break;
				}
			}
		}
	}
}