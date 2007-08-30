package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetType extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetType(ws:WebService):void{
				this.ws = ws;
		}
		
		public function execute(typeid:String):void
		{
			// protect
			ws.get_type.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_type.arguments.skey 		= code.skey();			//- очередной ключ сессии
			
			// data
			ws.get_type.arguments.typeid  	= typeid;		//- идентификатор типа 
			
			//send data & set listener 
			ws.get_type();
			ws.get_type.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_type.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_TYPE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_TYPE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}