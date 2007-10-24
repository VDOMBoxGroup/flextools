package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSetName extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetName(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String, name:String):void
		{
			// protect
			ws.set_name.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_name.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.set_name.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_name.arguments.objid  	= objid;		//- идентификатор объекта 
			ws.set_name.arguments.name  	= name;			//- новое имя объекта 

			//send data & set listener 
			ws.set_name();
			ws.set_name.addEventListener(ResultEvent.RESULT,completeListener);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.set_name.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.SET_NAME_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_NAME_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}