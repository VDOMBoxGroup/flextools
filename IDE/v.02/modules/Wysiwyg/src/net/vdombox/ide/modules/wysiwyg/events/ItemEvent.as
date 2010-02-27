package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class ItemEvent extends Event
	{
		public static var CREATED : String = "created";
		public static var GET_RESOURCE : String = "getResource";
		public static var ITEM_CLICKED : String = "itemClicked";

		public function ItemEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ItemEvent( type, bubbles, cancelable );
		}
	}
}