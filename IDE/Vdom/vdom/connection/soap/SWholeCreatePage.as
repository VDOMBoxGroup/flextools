package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SWholeCreatePage extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SWholeCreatePage(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, sourceid:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
		
			//send data & set listener 
			ws.whole_create_page.addEventListener(ResultEvent.RESULT,completeListener);
			ws.whole_create_page(sid, skey, appid, sourceid);
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
				evt = new SoapEvent(SoapEvent.WHOLE_CREATE_PAGE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.WHOLE_CREATE_PAGE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}