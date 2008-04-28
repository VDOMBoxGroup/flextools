package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	public class SSetAttributes extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetAttributes(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String = '', objid:String = '', attr:String = ''):String
		{
			// protect
			var sid:String = code.sessionId;		// - идентификатор сессии 
			var skey:String = code.skey();			//- очередной ключ сессии 
			
			//data 
			//ws.set_attributes.arguments.appid  	= appid;		//- идентификатор приложения 
			//ws.set_attributes.arguments.objid  	= objid;		//- идентификатор объекта
			//ws.set_attributes.arguments.attr  	= attr;			//- имя атрибута  
			
			//send data & set listener 
			ws.set_attributes(sid, skey, appid, objid, attr);
			ws.set_attributes.addEventListener(ResultEvent.RESULT,completeListener);
			
			return skey;
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			//trace(ws.set_attributes.lastResult.Result);
			// get result 
			resultXML = <Result>{XMLList(event.result)}</Result>;
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