package
{
	import flash.events.Event;

	public class QueueEvent extends Event
	{
		public static const SOAP_EXCEPTION:String = 'request_SoapException';
		public static const UNKNOWN_ERROR:String = 'request_UnknownSoapError';
		public static const SUCCESS_RESPONSE:String = 'requestOk';
		public static const STANDART_ERROR:String = 'requestFault';
		public static const FINISH:String = 'end_of_Queue';
		
		public var message:String = '';
		
		public function QueueEvent(type:String, message:String='', bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
		
	}
}