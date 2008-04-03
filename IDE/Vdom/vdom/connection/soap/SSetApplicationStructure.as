package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSetApplicationStructure extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetApplicationStructure(ws:WebService):void{
				this.ws = ws;
		}
		
		public function execute(appid:String, struct:String):void
		{
			// protect
			ws.set_application_structure.arguments.sid 			= code.sessionId;		// - идентификатор сессии 
			ws.set_application_structure.arguments.skey 		= code.skey();			//- очередной ключ сессии
			
			// data
			ws.set_application_structure.arguments.appid  	= appid;		//- идентификатор типа 
			ws.set_application_structure.arguments.struct  	= struct;		//- идентификатор типа 
			trace('1 - SSetApplicationStructure: ')
			//send data & set listener 
			ws.set_application_structure();
			ws.set_application_structure.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			ws.set_application_structure.removeEventListener(ResultEvent.RESULT,completeListener);
			// get result 
			resultXML = <Result>{XMLList(event.result)}</Result>;
			resultXML = resultXML.Result[0];
		//	resultXML = XML(event.result);
		
			var evt:SoapEvent; 
			trace('2 - SSetApplicationStructure \n')
			// check Error
			if(resultXML.name().toString() == 'Error')
			{	
				evt = new SoapEvent(SoapEvent.SET_APPLICATION_STRUCTURE_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_APPLICATION_STRUCTURE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}