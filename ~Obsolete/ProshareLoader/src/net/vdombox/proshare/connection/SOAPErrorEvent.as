package net.vdombox.proshare.connection
{
	import flash.events.Event;

	public class SOAPErrorEvent extends Event
	{
		public static var CONNECTION_ERROR : String = "connectionError";
		public static var LOGIN_ERROR : String = "loginError";

		public var faultCode : String;
		public var faultString : String;
		public var faultDetail : String;

		public function SOAPErrorEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true,
								   faultCode : String = null, faultString : String = null,
								   faultDetail : String = null )
		{
			super( type, bubbles, cancelable );

			this.faultCode = faultCode;
			this.faultString = faultString;
			this.faultDetail = faultDetail;
		}

		override public function clone() : Event
		{
			return new SOAPErrorEvent( type, bubbles, cancelable, faultCode, faultString,
									   faultDetail );
		}
	}
}