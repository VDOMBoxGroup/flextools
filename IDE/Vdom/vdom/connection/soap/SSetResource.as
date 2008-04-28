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
		
		public function execute(appid:String, restype:String, resname:String, resdata:String  ):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 

			//send data & set listener 
			ws.set_resource.addEventListener(ResultEvent.RESULT,completeListener);
			ws.set_resource(sid, skey, appid,  restype, resname, resdata);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
		//	trace(event.result)
			resultXML = <Result>{XMLList(event.result)}</Result>;
			//resultXML = resultXML.Result[0];
		//	resultXML = XML(event.result);
			// get result 
		//	resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML == null)
			{
				
				evt = new SoapEvent(SoapEvent.SET_RESOURCE_ERROR, new XML('<error/>'));
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_RESOURCE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}