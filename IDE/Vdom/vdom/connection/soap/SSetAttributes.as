package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	public class SSetAttributes extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetAttributes(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String = '', objid:String = '', attr:String = ''):void
		{
			// protect
			ws.set_attributes.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_attributes.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			//data 
			ws.set_attributes.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_attributes.arguments.objid  	= objid;		//- идентификатор объекта
			ws.set_attributes.arguments.attr  	= attr;			//- имя атрибута  
			
			//send data & set listener 
			ws.set_attributes();
			ws.set_attributes.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			//trace(ws.set_attributes.lastResult.Result);
			// get result 
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_S_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_S_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}