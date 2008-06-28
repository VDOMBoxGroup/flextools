package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SExecuteObject extends EventDispatcher 
	{
		private static 	var instance:SExecuteObject;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SExecuteObject() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.execute_object .addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SExecuteObject 
		{
			if (!instance)
				instance = new SExecuteObject();
	
			return instance;
		}
		
		public function execute(appid:String, objid:String, func_name:String, xml_param:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.execute_object(sid, skey, appid, objid, func_name, xml_param);
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
				evt = new SoapEvent(SoapEvent.EXECUTE_OBJECT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.EXECUTE_OBJECT_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}
	