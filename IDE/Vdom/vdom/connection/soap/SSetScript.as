package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SSetScript extends EventDispatcher 
	{
		private static 	var instance:SSetScript;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetScript() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.set_script.addEventListener(ResultEvent.RESULT,completeListener);
		} 		
		 
		 // initialization		
		public static function getInstance():SSetScript 
		{
			if (!instance)
				instance = new SSetScript();
	
			return instance;
		}
		
		public function execute(appid:String, objid:String, script:String, lang:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.set_script(sid, skey, appid, objid, script, lang);
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
				evt = new SoapEvent(SoapEvent.SET_SCRIPT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_SCRIPT_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}