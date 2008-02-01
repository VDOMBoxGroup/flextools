package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSetScript extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetScript(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String,objid:String, script:String ):void
		{
			// protect
			ws.set_script.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_script.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			//data
			ws.set_script.arguments.appid  		= appid;		//- идентификатор приложения 
			ws.set_script.arguments.objid  		= objid;		//- идентификатор объекта
			ws.set_script.arguments.script  	= script;		//- текст скрипта 
			
			//send data & set listener 
			ws.set_script();
			ws.set_script.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.SET_SCRIPT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_SCRIPT_ERROR, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}