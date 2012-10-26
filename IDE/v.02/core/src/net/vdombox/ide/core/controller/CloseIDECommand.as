package net.vdombox.ide.core.controller
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.Event;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CloseIDECommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var exitingEvent : Event = new Event( Event.EXITING, false, true );
			NativeApplication.nativeApplication.autoExit = true;
			NativeApplication.nativeApplication.addEventListener( Event.EXITING, exitingHandler );
			
			NativeApplication.nativeApplication.dispatchEvent(exitingEvent);
			
			if (!exitingEvent.isDefaultPrevented()) 
				NativeApplication.nativeApplication.exit();
		}
		
		private function exitingHandler( event : Event ) : void
		{
			NativeApplication.nativeApplication.removeEventListener( Event.EXITING, exitingHandler );
			
			var winClosingEvent:Event;
			var opened : Array = NativeApplication.nativeApplication.openedWindows;
			
			for each (var win : NativeWindow in opened ) 
			{
				winClosingEvent = new Event(Event.CLOSING,false,true);
				win.dispatchEvent(winClosingEvent);
				
				if (!winClosingEvent.isDefaultPrevented()) 
					win.close();
				else 
					event.preventDefault();
			}
			
			if (!event.isDefaultPrevented()) 
			{
				//perform cleanup
			}
		}
	}
}
