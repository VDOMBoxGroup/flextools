package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;
	
	public class AttributeEvent extends Event
	{
		public static var SELECT_RESOURCE : String = "selectResource";
		
		public function AttributeEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new AttributeEvent( type, bubbles, cancelable );
		}
	}
}