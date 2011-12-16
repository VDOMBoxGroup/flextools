package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class EditorEvent extends Event
	{
		public static var REMOVED : String = "removedEditor";
		
		public function EditorEvent(type : String, bubbles : Boolean = false,
									cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new EditorEvent( type, bubbles, cancelable );
		}
	}
}