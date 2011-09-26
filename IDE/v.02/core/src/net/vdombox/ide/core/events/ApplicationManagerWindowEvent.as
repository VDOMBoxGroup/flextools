package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class ApplicationManagerWindowEvent extends Event
	{
		public static var CLOSE_WINDOW : String = "closeWindow";
		
		public function ApplicationManagerWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ApplicationManagerWindowEvent( type, bubbles, cancelable );
		}
	}
}