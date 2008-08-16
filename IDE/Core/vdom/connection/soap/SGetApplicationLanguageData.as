package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	public class SGetApplicationLanguageData extends EventDispatcher 
	{
		private static 	var instance:SGetApplicationLanguageData;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationLanguageData() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.get_application_language_data.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SGetApplicationLanguageData 
		{
			if (!instance)
				instance = new SGetApplicationLanguageData();
	
			return instance;
		}
		
		public function execute(appid:String):void
		{
			//  protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
		
			//send data & set listener 
			ws.get_application_language_data(sid, skey, appid);
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
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}