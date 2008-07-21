package libs
{
	import flash.events.Event;

	public class EManagerEvent extends Event
	{
		public static const COMPLETED:String = 'QueryCompleted';
		public var result:String;
		
		public function EManagerEvent(type:String, result:String="", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.result = result;
		}
		
	}
}