package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;

	
	
	public class SCloseSession extends EventDispatcher 
	{
		private static 	var instance:SCloseSession;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCloseSession() 
		{	
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.close_session.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SCloseSession 
		{
//			if (!instance)
				instance = new SCloseSession();
	
			return instance;
		}
		
		public function execute():void
		{
			// protect
			var sid:String		= code.sessionId;		// - идентификатор сессии 
			
			//send data
			ws.close_session();
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				evt = new SoapEvent(SoapEvent.CLOSE_SESSION_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.CLOSE_SESSION_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
			}
		}
	}
}