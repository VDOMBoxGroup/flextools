package net.vdombox.ide.core.events
{
	import flash.events.Event;
	
	import mx.rpc.AsyncToken;

	public class SOAPEvent extends Event
	{
		public static var INIT_COMPLETE : String = "Init Complete";
		public static var LOGIN_OK : String = "Login OK";
		public static var LOGOFF_OK : String = "Logoff OK";
		public static var RESULT : String = "Result";

		public var result : XML = new XML();
		public var token : AsyncToken;

		public function SOAPEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true,
								   result : XML = null, token : AsyncToken = null )
		{
			super( type, bubbles, cancelable );

			this.result = result;
			this.token = token;
		}

		override public function clone() : Event
		{
			return new SOAPEvent( type, bubbles, cancelable, result );
		}
	}
}