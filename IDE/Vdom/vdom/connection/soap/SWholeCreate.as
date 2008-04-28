package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SWholeCreate extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SWholeCreate(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, parentid:String, name:String, data:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.whole_create.addEventListener(ResultEvent.RESULT,completeListener);
			ws.whole_create(sid, skey, appid, parentid, name, data);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
		//	trace(ws.get_resource.lastResult.Result)
			resultXML = <Result />
			resultXML.appendChild(ws.whole_create.lastResult.Result);
			
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.WHOLE_CREATE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.WHOLE_CREATE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}