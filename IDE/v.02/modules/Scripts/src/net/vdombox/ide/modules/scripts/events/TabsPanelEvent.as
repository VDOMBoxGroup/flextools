package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class TabsPanelEvent extends Event
	{
		public static var SELECTED_TAB_CHANGED : String = "selectedLibraryChanged";
		
		public function TabsPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new TabsPanelEvent( type, bubbles, cancelable );
		}
	}
}