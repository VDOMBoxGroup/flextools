package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SSetAttribute extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetAttribute(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String, attr:String, value:String):void{
			// protect
			var sid:String 		= code.sessionId;		// - идентификатор сессии 
			var skey:String		= code.skey();			//- очередной ключ сессии 
			
			ws.set_attribute.addEventListener(ResultEvent.RESULT,completeListener);
			
			//send data & set listener 
			ws.set_attribute(sid, skey, appid, objid, attr, value);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}