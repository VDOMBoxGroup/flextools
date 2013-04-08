package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;

	public class LinkageEvent extends Event
	{
		public static var CREATED : String = "linkageCreated";

		public static var CLICK : String = "linkageClick";

		public static var REMOVED : String = "linkageRemoved";

		public static var INDEX_CHANGE : String = "linkageIndexChange";

		public var detail : Object;

		public function LinkageEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new LinkageEvent( type, bubbles, cancelable );
		}
	}
}
