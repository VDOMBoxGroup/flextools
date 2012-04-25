package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class FindBoxEvent extends Event
	{
		public static const CLOSE : String = "findClose";
		public static const FIND_TEXT_CHANGE : String = "findTextChange";
		
		public static const PREVIOUS_FIND_TEXT : String = "previousFindText";
		public static const NEXT_FIND_TEXT : String = "nextFindText";
		
		public static const REPLACE_TEXT : String = "replaceText";
		public static const REPLACE_ALL_TEXT : String = "replaceAllText";
		
		public function FindBoxEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new FindBoxEvent( type, bubbles, cancelable );
		}
	}
}