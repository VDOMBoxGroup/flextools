package net.vdombox.ide.modules.events.events
{
	import flash.events.Event;

	public class EventsPanelEvent extends Event
	{
		public static var CREATE_SERVER_ACTION_CLICK : String = "createServerActionClick";
		
		public function EventsPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new EventsPanelEvent( type, bubbles, cancelable );
		}
	}
}