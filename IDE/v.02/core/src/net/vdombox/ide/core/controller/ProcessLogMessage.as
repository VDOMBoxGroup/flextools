package net.vdombox.ide.core.controller
{
	import mx.utils.StringUtil;
	
	import net.vdombox.ide.common.LogMessage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessLogMessage extends SimpleCommand
	{
		private const MESSAGE_TEMPLATE : String = "[{0}] [{1}] [{2}] {3}";
		
		override public function execute( notification : INotification ) : void
		{
			var logMessage : LogMessage = notification.getBody() as LogMessage;

			trace( "Log: "+StringUtil.substitute( MESSAGE_TEMPLATE, logMessage.time,  LogMessage.LEVELS[ logMessage.logLevel ], logMessage.sender, logMessage.message ) );
		}
	}
}