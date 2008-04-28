package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SGetTopObjects extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetTopObjects(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String):void
		{
			// protect
			var sid:String 		= code.sessionId;		// - идентификатор сессии 
			var skey:String 		= code.skey();			//- очередной ключ сессии 
			
			// data
			//ws.get_top_objects.arguments.appid  	= appid;		//- идентификатор приложения 
			
			//send data & set listener
			ws.get_top_objects.addEventListener(ResultEvent.RESULT, completeListener);
			ws.get_top_objects(sid, skey, appid);
			
		}
		
		
		private function completeListener(event:ResultEvent):void
		{
			//old
		//	resultXML = <Result>{XMLList(event.result)}</Result>;
			
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.GET_TOP_OBJECTS_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_TOP_OBJECTS_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}