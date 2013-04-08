package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class WorkAreaEvent extends Event
	{
		public static var CHANGE : String = "wae_change";

		public function WorkAreaEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new WorkAreaEvent( type, bubbles, cancelable );
		}
	}
}
