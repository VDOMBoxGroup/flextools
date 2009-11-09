/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks - Prattler Module
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>

 Parts originally from: 
 PureMVC AS3 Demo – AIR RSS Headlines 
 Copyright (c) 2007-08 Simon Bailey <simon.bailey@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.messages.FilterControlMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class LoggingJunctionMediator extends JunctionMediator
	{

		/**
		 * Constructor.
		 * <P>
		 * Handles sending LogMessages.</P>
		 */ 		
		public function LoggingJunctionMediator( name:String, junction:Junction )
		{
			super( name, junction );
			
		}

		/**
		 * List Notification Interests.
		 * <P>
		 * Adds subclass interests to those of the JunctionMediator.</P>
		 */
		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(LogMessage.SEND_TO_LOG);
			interests.push(LogFilterMessage.SET_LOG_LEVEL);
			return interests;
		}

		/**
		 * Handle Logging related Notifications for a JunctionMediator subclass.
		 * <P>
		 * Override in subclass and call super.handleNotification to 
		 * Send messages to the logger and set the log level as well as
		 * IPipeAware actions (accepting input/output pipes).</P>
		 */		
		override public function handleNotification( note:INotification ):void
		{
			
			switch( note.getName() )
			{
                // Send messages to the Log
                case LogMessage.SEND_TO_LOG:
                    var level:int;
                    switch (note.getType())
                    {
                        case LogMessage.LEVELS[LogMessage.DEBUG]:
                            level = LogMessage.DEBUG;
                            break;

                        case LogMessage.LEVELS[LogMessage.ERROR]:
                            level = LogMessage.ERROR;
                            break;
                        
                        case LogMessage.LEVELS[LogMessage.FATAL]:
                            level = LogMessage.FATAL;
                            break;
                        
                        case LogMessage.LEVELS[LogMessage.INFO]:
                            level = LogMessage.INFO;
                            break;
                        
                        case LogMessage.LEVELS[LogMessage.WARN]:
                            level = LogMessage.WARN;
                            break;
                        
                        default:
                            level = LogMessage.DEBUG;
                            break;
                        
                    }
                    var logMessage:LogMessage = new LogMessage( level, this.multitonKey, note.getBody() as String);
                    junction.sendMessage( VIModule.STDLOG, logMessage );
                    break;

                // Modify the Log Level filter 
                case LogFilterMessage.SET_LOG_LEVEL:
                    var logLevel:number = note.getBody() as Number;
                    var setLogLevelMessage:LogFilterMessage = new LogFilterMessage(FilterControlMessage.SET_PARAMS, logLevel);
                    var changedLevel:Boolean = junction.sendMessage( VIModule.STDLOG, setLogLevelMessage );
                    var changedLevelMessage:LogMessage = new LogMessage( LogMessage.CHANGE, this.multitonKey, "Changed Log Level to: "+LogMessage.LEVELS[logLevel])
                    var logChanged:Boolean = junction.sendMessage( VIModule.STDLOG, changedLevelMessage );
                    break;

				
				// And let super handle the rest (ACCEPT_OUTPUT_PIPE, ACCEPT_INPUT_PIPE, SEND_TO_LOG)								
				default:
					super.handleNotification(note);
					
			}
		}
		
	}
}