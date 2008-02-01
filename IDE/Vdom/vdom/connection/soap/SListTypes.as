package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SListTypes extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SListTypes(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void
		{
			// protect
			ws.list_types.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.list_types.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			//send data & set listener 
			ws.list_types();
			ws.list_types.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				evt = new SoapEvent(SoapEvent.LIST_TYPES_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.LIST_TYPES_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}