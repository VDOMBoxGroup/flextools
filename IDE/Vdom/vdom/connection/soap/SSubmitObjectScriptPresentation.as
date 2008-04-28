package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSubmitObjectScriptPresentation extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSubmitObjectScriptPresentation(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( appid:String = '', objid:String = '', pres:String = '' ):void
		{
			// protect
			ws.submit_object_script_presentation.arguments.sid 			= code.sessionId; 		// - идентификатор сессии 
			ws.submit_object_script_presentation.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
	/*		// data
			ws.submit_object_script_presentation.arguments.appid  		= appid;				//- идентификатор приложения 
			ws.submit_object_script_presentation.arguments.objid  		= objid;				//- идентификатор объекта
			ws.submit_object_script_presentation.arguments.pres  		= pres;
		*/	
			//send data & set listener 
			ws.submit_object_script_presentation(appid, objid, pres);
			ws.submit_object_script_presentation.addEventListener(ResultEvent.RESULT, completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			resultXML = <Result>{XMLList(event.result)}</Result>;
			resultXML = resultXML.Types[0];
			
			var evt:SoapEvent;

			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_ERROR, resultXML );
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SUBMIT_OBJECT_SCRIPT_PRESENTATION_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}