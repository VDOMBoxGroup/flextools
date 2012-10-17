package net.vdombox.ide.common.controller.messages
{
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.FilterControlMessage;

	public class LogFilterMessage extends FilterControlMessage
	{
		protected static const BASE:String 			= FilterControlMessage.BASE+'/LoggerModule/'
		public static const LOG_FILTER_NAME:String 	= BASE+'/LoggerModule/logFilter/';
		public static const SET_LOG_LEVEL:String 	= BASE+'LoggerModule/setLogLevel';
		
		public var logLevel:Number;

		public function LogFilterMessage( action:String, logLevel:Number=0 )
		{
			super( action, LOG_FILTER_NAME, null, {logLevel:logLevel});
			this.logLevel=logLevel; 
		}
		
		public static function filterLogByLevel( message:IPipeMessage, params:Object):void		
		{
			if (message.getHeader().logLevel > params.logLevel) { throw new Error(); }
		}
		
	}
}