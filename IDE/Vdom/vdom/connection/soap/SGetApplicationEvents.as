package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;

	public class SGetApplicationEvents extends EventDispatcher 
	{
		private static 	var instance:SGetApplicationEvents;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationEvents()
		{
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.get_application_events.addEventListener(ResultEvent.RESULT,completeListener);
		} 		
		 
		 // initialization		
		public static function getInstance():SGetApplicationEvents 
		{
			if (!instance)
				instance = new SGetApplicationEvents();
	
			return instance;
		}
		
		public function execute(appid:String, objid:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.get_application_events(sid, skey, appid, objid);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_EVENTS_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_EVENTS_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}