package net.vdombox.components.xmldialogeditor.events
{
	import flash.events.Event;
	
	public class AttributesItemRendererEvent extends Event
	{
		public static const UPDATED : String = "attributesItemRendererUpdated"
		
		public function AttributesItemRendererEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new AttributesItemRendererEvent( type, bubbles, cancelable );
		}
	}
}