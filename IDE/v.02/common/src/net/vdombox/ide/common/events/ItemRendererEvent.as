package net.vdombox.ide.common.events
{
	import flash.events.Event;
	
	public class ItemRendererEvent extends Event
	{
		public static var CREATED : String = "created";
		public static var DOUBLE_CLICK : String = "itemRendererDoubleClick";
		
		public function ItemRendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ItemRendererEvent( type, bubbles, cancelable );
		}
	}
}