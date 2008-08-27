package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	public class SCreateApplication extends EventDispatcher
	{
		private static 	var instance:SCreateApplication;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateApplication() 
		{	
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.create_application.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SCreateApplication 
		{
//			if (!instance)
				instance = new SCreateApplication();
	
			return instance;
		}
		
		public function execute(attr:XML):void
		{
			//  protect
			var sid:String = code.sessionId;		// - идентификатор сессии 
			var skey:String = code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener
			ws.create_application(sid, skey, attr);
			
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
				evt = new SoapEvent(SoapEvent.CREATE_APPLICATION_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.CREATE_APPLICATION_OK, resultXML);
				dispatchEvent(evt);
			}
		}
		
	}
}