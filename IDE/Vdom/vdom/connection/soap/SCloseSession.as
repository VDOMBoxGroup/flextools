package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	import vdom.connection.protect.Code;
	
	
	public class SCloseSession extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCloseSession(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void
		{
			// protect
			ws.close_session.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			
			// no data
			
			//send data & set listener 
			ws.close_session();
			ws.close_session.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.close_session.lastResult.Result);
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