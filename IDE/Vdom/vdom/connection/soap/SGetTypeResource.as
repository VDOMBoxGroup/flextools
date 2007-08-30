package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetTypeResource extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetTypeResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(typeid:String, resid:String):void
		{
			// protect
			ws.get_type_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_type_resource.arguments.skey 		= code.skey();		//- очередной ключ сессии 
			
			// data
			ws.get_type_resource.arguments.typeid  	= typeid;				//- идентификатор типа
			ws.get_type_resource.arguments.resid  	= resid;				//- идентификатор ресурса
			
			//send data & set listener 
			ws.get_type_resource();
			ws.get_type_resource.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_type_resource.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.GET_TYPE_RESOURCE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_TYPE_RESOURCE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}