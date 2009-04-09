package net.vdombox.ide.events
{
	import flash.events.Event;

	public class SOAPEvent extends Event
	{
		public static var INIT_COMPLETE : String = "Init Complete";
		public static var LOGIN_OK : String = "Login OK";
		public static var RESULT : String = "Result";

		public var result : XML = new XML();

		public function SOAPEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true,
								   result : XML = null )
		{
			super( type, bubbles, cancelable );

			this.result = result;
		}

		override public function clone() : Event
		{
			return new SOAPEvent( type, bubbles, cancelable, result );
		}
	}
}