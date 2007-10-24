package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SWoleCreatePage extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, sourceid:String):void
		{
			// protect
			ws.whole_create_page.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.whole_create_page.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.whole_create_page.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.whole_create_page.arguments.sourceid  	= sourceid;		//-  идентификатор объекта, используемого 
																		//   в качестве шаблона для новой страницы 

			//send data & set listener 
			ws.whole_create_page();
			ws.whole_create_page.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.whole_create_page.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.WOLE_CREATE_PAGE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.WOLE_CREATE_PAGE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}