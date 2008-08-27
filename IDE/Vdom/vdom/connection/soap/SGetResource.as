package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SGetResource extends EventDispatcher 
	{	
		private static 	var instance:SGetResource;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code = Code.getInstance();
		
		public function SGetResource() 
		{	
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.get_resource.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SGetResource 
		{
//			if (!instance)
				instance = new SGetResource();
	
			return instance;
		}

		public function execute(ownerid:String, resid:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String 		= code.skey();	//- очередной ключ сессии 
			
			//send data 
			
			ws.get_resource(sid, skey, ownerid, resid);
		}
		
		
		private function completeListener(event:ResultEvent):void
		{
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.GET_RESOURCE_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.GET_RESOURCE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}