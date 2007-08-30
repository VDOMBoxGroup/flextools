package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	public class SGetApplicationLanguageData extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationLanguageData(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String):void
		{
			//  protect
			ws.get_application_language_data.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_application_language_data.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data 
			ws.get_application_language_data.arguments.appid  	= appid;		//- идентификатор приложения 
			
			//send data & set listener 
			ws.get_application_language_data();
			ws.get_application_language_data.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_application_language_data.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}