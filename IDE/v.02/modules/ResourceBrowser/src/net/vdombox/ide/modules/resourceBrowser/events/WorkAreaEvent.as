package net.vdombox.ide.modules.resourceBrowser.events
{
	import flash.events.Event;

	public class WorkAreaEvent extends Event
	{
		public static var DELETE_RESOURCE : String = "deleteREsource";
		public static var LOAD_RESOURCE : String = "loadREsource";
		public static var GET_ICON : String = "getIcon";
		public static var ERROR : String = "workError";
		
		public var content : String;

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