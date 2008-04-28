package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetApplicationStructure extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationStructure(ws:WebService):void{
				this.ws = ws;
		}
		
		public function execute(appid:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.get_application_structure.addEventListener(ResultEvent.RESULT,completeListener);
			ws.get_application_structure(sid, skey, appid);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			ws.get_application_structure.removeEventListener(ResultEvent.RESULT, completeListener);
			// get result 
			resultXML = <Result>{XMLList(event.result)}</Result>;
			resultXML = resultXML.Structure[0];
			//resultXML = XML(event.result);
			var evt:SoapEvent;
			trace('2 - get_application_structure Resoult \n');
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_STRUCTURE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_STRUCTURE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}