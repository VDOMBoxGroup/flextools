package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	
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