package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetResource  extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(ownerid:String, resid:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			
			//send data & set listener 
			ws.get_resource.addEventListener(ResultEvent.RESULT,completeListener);
			ws.get_resource(sid, skey, ownerid, resid);
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
				evt = new SoapEvent(SoapEvent.GET_RESOURCE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_RESOURCE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}