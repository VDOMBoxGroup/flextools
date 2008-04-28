package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SSetApplicationInfo extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetApplicationInfo(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, attrname:String, attrvalue:String ):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 

			
			
			//send data & set listener 
			ws.set_application_info(sid, skey, appid, attrname, attrvalue);
			ws.set_application_info.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.SET_APLICATION_ERROR, resultXML);
				dispatchEvent(evt);
			} else{

				evt = new SoapEvent(SoapEvent.SET_APLICATION_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}