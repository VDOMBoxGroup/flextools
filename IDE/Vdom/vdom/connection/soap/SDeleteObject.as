package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SDeleteObject extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SDeleteObject(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( appid:String = '', objid:String = '' ):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.delete_object.addEventListener(ResultEvent.RESULT,completeListener);
			ws.delete_object(sid, skey, appid, objid);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = <Result>{XMLList(event.result)}</Result>;
			resultXML = resultXML.Result[0];
		//	resultXML = XML(event.result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.DELETE_OBJECT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.DELETE_OBJECT_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}