package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetTopObjects extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetTopObjects(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String):void
		{
			// protect
			ws.get_top_objects.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_top_objects.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.get_top_objects.arguments.appid  	= appid;		//- идентификатор приложения 
			
			//send data & set listener 
			ws.get_top_objects();
			ws.get_top_objects.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				evt = new SoapEvent(SoapEvent.GET_TOP_OBJECTS_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_TOP_OBJECTS_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}