package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetEcho extends EventDispatcher
	{
		private static 	var instance:SGetEcho;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetEcho() 
		{	
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.get_echo.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SGetEcho 
		{
//			if (!instance)
				instance = new SGetEcho();
	
			return instance;
		}
		
		public function execute():void
		{
			// protect
			ws.get_echo.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.get_echo();
			
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
				evt = new SoapEvent(SoapEvent.GET_ECHO_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.GET_ECHO_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}