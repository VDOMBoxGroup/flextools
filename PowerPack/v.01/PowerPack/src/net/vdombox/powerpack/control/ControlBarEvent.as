package net.vdombox.powerpack.control
{
	import flash.events.Event;
	
	public class ControlBarEvent extends Event
	{
		public static const EVENT_ITEM_CLICK			: String = "controlBarItemClick";
		
		public var targetItemType			: String;
		public var destinationObjectType		: String;
		
		public function ControlBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ControlBarEvent(type, bubbles, cancelable);
		}
		
	}
}