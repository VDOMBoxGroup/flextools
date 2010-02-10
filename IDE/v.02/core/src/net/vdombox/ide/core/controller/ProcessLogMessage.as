package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.LogMessage;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessLogMessage extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var logMessage : LogMessage = notification.getBody() as LogMessage;

			trace( "[" + logMessage.time + "]" + "[" + LogMessage.LEVELS[ logMessage.logLevel ] + "]" + "[" + logMessage.sender + "]" + "[" +
				logMessage.message + "]" )
		}
	}
}