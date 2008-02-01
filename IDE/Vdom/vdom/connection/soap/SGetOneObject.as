package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetOneObject extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetOneObject(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( appid:String = '', objid:String = '' ):void
		{
			// protect
			ws.get_one_object.arguments.sid 			= code.sessionId; 		// - идентификатор сессии 
			ws.get_one_object.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.get_one_object.arguments.appid  		= appid;				//- идентификатор приложения 
			ws.get_one_object.arguments.objid  		= objid;				//- идентификатор объекта

			
			//send data & set listener 
			ws.get_one_object();
			ws.get_one_object.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_ONE_OBJECT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_ONE_OBJECT_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}