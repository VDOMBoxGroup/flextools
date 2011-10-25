package net.vdombox.ide.modules.events.events
{
	import flash.events.Event;

	public class WorkAreaEvent extends Event
	{
		public static var SAVE : String = "save";
		public static var UNDO : String = "undo";
		public static var SHOW_ELEMENTS : String = "showElements";
		public static var CREATE_ELEMENTS : String = "createElements";
		public static var DELETE_ELEMENT : String = "deleteElement";
		
		public function WorkAreaEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new WorkAreaEvent( type, bubbles, cancelable );
		}
	}
}