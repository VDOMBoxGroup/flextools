package vdom.events
{
	import flash.events.Event;

	public class ServerScriptsEvent extends Event
	{
		public static  const DATA_CHANGED:String = 'dataChanged';
		
		public var data:String;
		
		public function ServerScriptsEvent(type:String,  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			
		}
		
	}
}