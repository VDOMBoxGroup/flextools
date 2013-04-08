package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class AlertWindowEvent extends Event
	{
		public static var OK : String = "alertOK";

		public static var NO : String = "alertNO";

		public function AlertWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new AlertWindowEvent( type, bubbles, cancelable );
		}
	}
}
