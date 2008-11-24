package vdom.events
{
	import flash.events.Event;

	public class IndexEvent extends Event
	{
		public static const CHANGE:String = 'change';
		
		public var lastIndex:int;
		public var newIndex:int;
		public var level:String;
		public var fromObjectID:String;
		
		public function IndexEvent(type:String, newIndex:int, lastIndex:int, level:String, fromObjectID:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.lastIndex = lastIndex;
			this.newIndex = newIndex;
			this.level = level;
			this.fromObjectID = fromObjectID;
		}

	}
}