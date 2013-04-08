package net.vdombox.ide.core.events
{
	import flash.events.Event;

	public class IconChooserEvent extends Event
	{
		public static var LOAD_ICON : String = "loadIcon";

		public static var OPEN_ICON_LIST : String = "openIconList";

		public static var CLOSE_ICON_LIST : String = "closeIconList";

		public static var SELECT_ICON : String = "selectIcon";

		public function IconChooserEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	}
}
