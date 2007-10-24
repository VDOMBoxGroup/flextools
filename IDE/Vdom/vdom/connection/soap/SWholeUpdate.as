package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SWholeUpdate extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SWholeUpdate(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String, data:String):void
		{
			// protect
			ws.whole_update.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.whole_update.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.whole_update.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.whole_update.arguments.objid  	= objid;		//- идентификатор объекта 
			ws.whole_update.arguments.data  	= data;			//- xml описание WHOLE объекта 

			//send data & set listener 
			ws.whole_update();
			ws.whole_update.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.whole_update.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.WHOLE_UPDATE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.WHOLE_UPDATE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}