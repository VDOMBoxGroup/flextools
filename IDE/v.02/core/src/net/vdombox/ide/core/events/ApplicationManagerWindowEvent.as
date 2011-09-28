package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class ApplicationManagerWindowEvent extends Event
	{
		public static var CLOSE_WINDOW : String = "closeWindow";
		public static var OPEN_IN_EDITOR : String = "openInEditor";
		public static var OPEN_IN_EDIT_VIEW : String = "openInEditView";
		public static var SAVE_INFORMATION : String = "saveInformation";
		
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