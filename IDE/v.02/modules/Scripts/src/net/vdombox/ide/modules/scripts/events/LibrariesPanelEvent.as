package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;
	
	public class LibrariesPanelEvent extends Event
	{
		public static var SELECTED_LIBRARY_CHANGED : String = "selectedLibraryChanged";
		public static var CREATE_LIBRARY : String = "createLibrary";
		public static var DELETE_LIBRARY : String = "deleteLibrary";
		
		public function LibrariesPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new LibrariesPanelEvent( type, bubbles, cancelable );
		}
	}
}