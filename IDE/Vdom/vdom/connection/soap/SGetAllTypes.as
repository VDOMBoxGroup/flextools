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
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.get_all_types.addEventListener(ResultEvent.RESULT,completeListener);
			ws.get_all_types(sid, skey);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = <Result>{XMLList(event.result)}</Result>;
			resultXML = resultXML.Types[0]
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
	