package events
{
	import flash.events.Event;
	
	public class ContactsProxyEvent extends Event
	{
		public var message : String;
		
		public static const INFORMATION : String = "information";

		public static const FAULT : String = "fault";
		
		
		
		public function ContactsProxyEvent(type:String, message : String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
		
		
		
		override public function clone():Event
		{
			
			return new ContactsProxyEvent(type, message, bubbles, cancelable);
		}
		
		
	}
}