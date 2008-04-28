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
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
		
			//send data & set listener 
			ws.get_application_language_data.addEventListener(ResultEvent.RESULT,completeListener);
			ws.get_application_language_data(sid, skey, appid);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
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