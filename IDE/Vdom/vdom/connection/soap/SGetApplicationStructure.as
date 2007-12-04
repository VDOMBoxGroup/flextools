package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetApplicationStructure extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationStructure(ws:WebService):void{
				this.ws = ws;
		}
		
		public function execute(appid:String):void
		{
			// protect
			ws.get_application_structure.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_application_structure.arguments.skey 		= code.skey();			//- очередной ключ сессии
			
			// data
			ws.get_application_structure.arguments.appid  	= appid;		//- идентификатор типа 
			
			//send data & set listener 
			ws.get_application_structure();
			ws.get_application_structure.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_application_structure.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_STRUCTURE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_STRUCTURE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}