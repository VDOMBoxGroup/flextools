package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ProcessServerProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			switch ( message.getTarget() )
			{
				case "":
				{
					break;
				}
			}
		}
	}
}