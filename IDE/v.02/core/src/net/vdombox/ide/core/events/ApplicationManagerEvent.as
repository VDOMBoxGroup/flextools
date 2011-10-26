package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class ApplicationManagerEvent extends Event
	{
		// FIXME: need to rename
		public static var CLOSE_WINDOW : String = "closeWindow";
		public static var SET_SELECTED_APPLICATION_REQUEST : String = "setSelectedApplicationRequest";
		public static var EDIT_SELECTED_APPLICATION_REQUEST : String = "editSelectedApplicationRequest";
		public static var CREATE_NEW_APPLICATION_REQUEST : String = "createNewApplicationRequest";
		public static var SAVE_INFORMATION : String = "saveInformation";
		public static var CANCEL : String = "CancelEdit";
		
		public function ApplicationManagerEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ApplicationManagerEvent( type, bubbles, cancelable );
		}
	}
}