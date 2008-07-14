package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SRemoteMethodCall extends EventDispatcher 
	{
		private static 	var instance:SRemoteMethodCall;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SRemoteMethodCall() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.remote_method_call.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SRemoteMethodCall 
		{
			if (!instance)
				instance = new SRemoteMethodCall();
	
			return instance;
		}
		
		public function execute(appid:String, objid:String, func_name:String, xml_param:String):String
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.remote_method_call(sid, skey, appid, objid, func_name, xml_param);
			return skey;
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));
			
			// old
			//resultXML = <Result>{XMLList(event.result)}</Result>;
			//resultXML = resultXML.Types[0]

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.REMOTE_METHOD_CALL_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.REMOTE_METHOD_CALL_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}
	