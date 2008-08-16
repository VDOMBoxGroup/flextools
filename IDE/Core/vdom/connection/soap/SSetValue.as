package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	public class SSetValue extends EventDispatcher 
	{
		private static 	var instance:SSetValue;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetValue() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.set_value.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SSetValue 
		{
			if (!instance)
				instance = new SSetValue();
	
			return instance;
		}
		
		public function execute(appid:String,objid:String, value:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.set_value(sid, skey, appid, objid, value);
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
				evt = new SoapEvent(SoapEvent.SET_VALUE_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.SET_VALUE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}