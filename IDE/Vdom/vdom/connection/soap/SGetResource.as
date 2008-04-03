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
			ws.get_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_resource.arguments.skey 		= code.skey();		//- очередной ключ сессии 
			
			// data
			ws.get_resource.arguments.ownerid  	= ownerid;				//- идентификатор типа
			ws.get_resource.arguments.resid  	= resid;				//- идентификатор ресурса
		//	trace('SOAP get_resource as: '+resid )
			
			//send data & set listener 
			ws.get_resource();
			ws.get_resource.addEventListener(ResultEvent.RESULT,completeListener);
			//trace('loadBegin');
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
		//	trace(ws.get_resource.lastResult.Result)
			//trace('loadBeginComplete');
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));
		//	trace('SOAP get_resource: '+event.result)
			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != ''){

				evt = new SoapEvent(SoapEvent.GET_RESOURCE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_RESOURCE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}