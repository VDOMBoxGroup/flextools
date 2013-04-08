package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class ErrorViewEvent extends Event
	{
		public static var BACK : String = "back";

		public function ErrorViewEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new InitialWindowEvent( type, bubbles, cancelable );
		}
	}
}
