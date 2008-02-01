package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSetResource extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, resid:String, restype:String, resname:String, resdata:String  ):void
		{
			// protect
			ws.set_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_resource.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.set_resource.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_resource.arguments.restype  	= restype;		//- идентификатор приложения 
			ws.set_resource.arguments.resname  	= resname;		//- идентификатор приложения 
			ws.set_resource.arguments.resid  	= resid;		//- идентификатор ресурса: необходимо указывать для изменения существующего ресурса; 
																	// для добавления нового - пустая строка
			ws.set_resource.arguments.resdata  	= resdata;		//- текст скрипта 

			//send data & set listener 
			ws.set_resource();
			ws.set_resource.addEventListener(ResultEvent.RESULT,completeListener);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.SET_RESOURCE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_RESOURCE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}