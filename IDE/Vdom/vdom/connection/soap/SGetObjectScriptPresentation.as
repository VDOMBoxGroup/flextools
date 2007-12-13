package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SGetObjectScriptPresentation extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetObjectScriptPresentation(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( appid:String = '', objid:String = '' ):void
		{
			// protect
			ws.get_object_script_presentation.arguments.sid 			= code.sessionId; 		// - идентификатор сессии 
			ws.get_object_script_presentation.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.get_object_script_presentation.arguments.appid  		= appid;				//- идентификатор приложения 
			ws.get_object_script_presentation.arguments.objid  		= objid;				//- идентификатор объекта
			
			//send data & set listener 
			ws.get_object_script_presentation();
			ws.get_object_script_presentation.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_object_script_presentation.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_OBJECT_SCRIPT_PRESENTATION_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}