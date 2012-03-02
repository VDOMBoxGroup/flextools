package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class TabsPanelEvent extends Event
	{
		public static var SELECTED_TAB_CHANGED : String = "selectedLibraryChanged";
		public static var TAB_DELETE : String = "tabDelete";
		
		public var tab : Object;
		
		public function TabsPanelEvent( type : String, _tab : Object = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
			tab = _tab;
		}
		
		override public function clone() : Event
		{
			return new TabsPanelEvent( type, bubbles, cancelable );
		}
	}
}