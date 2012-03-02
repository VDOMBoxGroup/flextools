package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class ListItemRendererEvent extends Event
	{
		public static var ITEM_CHENGED : String = "itemChanged";
		public static var DELETE_PRESS : String = "deletePress";
		
		public function ListItemRendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ListItemRendererEvent( type, bubbles, cancelable );
		}
	}
}