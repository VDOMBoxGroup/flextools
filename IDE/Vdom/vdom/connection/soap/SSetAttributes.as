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
			
			//send data & set listener 
			ws.set_attributes(sid, skey, appid, objid, attr);
			ws.set_attributes.addEventListener(ResultEvent.RESULT,completeListener);
			
			return skey;
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
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_S_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_S_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}