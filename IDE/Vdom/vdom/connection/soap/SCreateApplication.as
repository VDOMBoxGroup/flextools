package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	public class SCreateApplication extends EventDispatcher
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateApplication(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(attr:XML):void
		{
			//  protect
			var sid:String = code.sessionId;		// - идентификатор сессии 
			var skey:String = code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener
			ws.create_application.addEventListener(ResultEvent.RESULT,completeListener); 
			ws.create_application(sid, skey, attr);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(<Result>{XMLList(event.result)}</Result>);
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