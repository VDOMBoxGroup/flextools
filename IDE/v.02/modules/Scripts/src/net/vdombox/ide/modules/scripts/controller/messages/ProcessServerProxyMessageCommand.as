package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMServerTargetNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ProcessServerProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			switch ( message.target )
			{
				case "":
				{
					break;
				}
			}
		}
	}
}