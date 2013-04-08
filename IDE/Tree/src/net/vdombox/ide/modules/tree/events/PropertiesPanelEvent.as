package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;

	public class PropertiesPanelEvent extends Event
	{
		public static var SAVE_PAGE_ATTRIBUTES : String = "savePageAttributes";

		public static var SAVE_PAGE_NAME : String = "savePageName";

		public static var MAKE_START_PAGE : String = "makeStartPage";

		public static var DELETE_PAGE : String = "deletePages";

		public function PropertiesPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new PropertiesPanelEvent( type, bubbles, cancelable );
		}
	}
}
