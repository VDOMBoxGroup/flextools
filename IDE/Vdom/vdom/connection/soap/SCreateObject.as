package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SCreateObject extends EventDispatcher
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateObject(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String='',parentid:String='',typeid:String = '', attrs:String = '', name:String =''):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			
			//send data & set listener 
			ws.create_object.addEventListener(ResultEvent.RESULT,completeListener);
			ws.create_object(sid, skey, appid, parentid, typeid, attrs, name);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.CREATE_OBJECT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.CREATE_OBJECT_OK,resultXML);
				dispatchEvent(evt);
			}
		}
	}
}