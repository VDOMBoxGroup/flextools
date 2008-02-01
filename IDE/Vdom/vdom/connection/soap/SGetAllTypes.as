package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetAllTypes extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetAllTypes(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void
		{
			// protect
			ws.get_all_types.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_all_types.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.get_all_types();
			ws.get_all_types.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;

			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_ALL_TYPES_ERROR,resultXML );
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_ALL_TYPES_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}
	