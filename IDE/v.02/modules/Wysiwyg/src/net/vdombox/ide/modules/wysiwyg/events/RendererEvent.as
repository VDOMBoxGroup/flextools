package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class RendererEvent extends Event
	{
		public static var CREATED : String = "itemCreated";
		public static var REMOVED : String = "itemRemoved";
		public static var GET_RESOURCE : String = "getResource";
		public static var ITEM_CLICKED : String = "itemClicked";

		public function RendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new RendererEvent( type, bubbles, cancelable );
		}
	}
}