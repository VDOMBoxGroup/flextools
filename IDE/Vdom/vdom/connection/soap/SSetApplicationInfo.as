package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SSetApplicationInfo extends EventDispatcher 
	{
		private static 	var instance:SSetApplicationInfo;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetApplicationInfo() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.set_application_info.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SSetApplicationInfo 
		{
			if (!instance)
				instance = new SSetApplicationInfo();
	
			return instance;
		}
		
		public function execute(appid:String, attr:String ):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 

			
			
			//send data & set listener 
			ws.set_application_info(sid, skey, appid, attr);
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
				evt = new SoapEvent(SoapEvent.SET_APLICATION_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.SET_APLICATION_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}