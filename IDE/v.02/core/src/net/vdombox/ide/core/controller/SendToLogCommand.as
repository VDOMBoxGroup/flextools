package net.vdombox.ide.core.controller
{
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SendToLogCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			trace( notification.getBody() );
		}
	}
}