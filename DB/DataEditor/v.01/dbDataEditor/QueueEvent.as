package
{
	import flash.events.Event;

	public class QueueEvent extends Event
	{
		public static const SOAP_EXCEPTION:String = 'request_SoapException';
		public static const UNKNOWN_ERROR:String = 'request_UnknownSoapError';
		public static const SUCCESS_RESPONSE:String = 'requestOk';
		public static const STANDART_ERROR:String = 'requestFault';
		public static const QUEUE_COMPLETE:String = 'end_of_Queue';
		public static const QUEUE_INTERRUPT:String = 'queue_interrupt';
		
		public var message:String = '';
		public var position:int = 0;
		
		public function QueueEvent(type:String, message:String='', position:int=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
			
			this.message = message;
			this.position = position;
		}
		
	}
}