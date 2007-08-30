package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSetAttribute extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetAttribute(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String,objid:String, attr:String, value:String):void{
			// protect
			ws.set_attribute.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_attribute.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.set_attribute.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_attribute.arguments.objid  	= objid;		//- идентификатор объекта
			ws.set_attribute.arguments.attr  	= attr;			//- имя атрибута  
			ws.set_attribute.arguments.value 	= value;		//- значение атрибута
			
			//send data & set listener 
			ws.set_attribute();
			ws.set_attribute.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.set_attribute.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}