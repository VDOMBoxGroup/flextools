package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SModifyResource extends EventDispatcher 
	{
		private static 	var instance:SModifyResource;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SModifyResource() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.modify_resource.addEventListener(ResultEvent.RESULT, completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SModifyResource 
		{
			if (!instance)
				instance = new SModifyResource();
	
			return instance;
		}
		
		public function execute( appid:String = '', objid:String = '', 
													resid:String = '', 
													attrname:String = '', 
													operation:String = '',
													attr:String = ''	 ):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.modify_resource(sid, skey, appid, objid, resid, attrname, operation, attr);
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
				evt = new SoapEvent(SoapEvent.MODIFY_RESOURSE_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.MODIFY_RESOURSE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}