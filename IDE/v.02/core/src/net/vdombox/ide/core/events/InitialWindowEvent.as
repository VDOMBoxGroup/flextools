package net.vdombox.ide.core.events
{
	import flash.events.Event;
	
	public class InitialWindowEvent extends Event
	{
		public static var EXIT : String = "exit1";
		public static var SUBMIT : String = "submit";
		
		public function InitialWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new InitialWindowEvent( type, bubbles, cancelable );
		}
	}
}