package vdom.connection.soap
{
	import flash.events.EventDispatcher;

	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;	
	
	public class SGetScript extends EventDispatcher 
	{
		private static 	var instance:SGetScript;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
		
		public function SGetScript()
		{
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.get_script.addEventListener(ResultEvent.RESULT,completeListener);
		} 		
		 
		 // initialization		
		public static function getInstance():SGetScript 
		{
//			if (!instance)
				instance = new SGetScript();
	
			return instance;
		}
		
		public function execute(appid:String,objid:String, lang:String ):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			
			//send data & set listener 
			ws.get_script(sid, skey, appid, objid, lang);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.GET_SCRIPT_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.GET_SCRIPT_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}