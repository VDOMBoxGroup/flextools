package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;
	
	public class ItemRendererEvent extends Event
	{
		public static var CREATED : String = "created";
		
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