package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	public class SCreateApplication extends EventDispatcher
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateApplication(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void
		{
			//  protect
			ws.create_application.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.create_application.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.create_application();
			ws.create_application.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.CREATE_APPLICATION_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.CREATE_APPLICATION_OK, resultXML);
				evt.result = resultXML;
				dispatchEvent(evt);
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}