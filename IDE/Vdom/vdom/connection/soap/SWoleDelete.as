package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SWoleDelete extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String):void
		{
			// protect
			ws.whole_delete.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.whole_delete.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.whole_delete.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.whole_delete.arguments.objid  	= objid;		//- идентификатор объекта 

			//send data & set listener 
			ws.whole_delete();
			ws.whole_delete.addEventListener(ResultEvent.RESULT,completeListener);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.whole_delete.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.WOLE_DELETE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.WOLE_DELETE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}