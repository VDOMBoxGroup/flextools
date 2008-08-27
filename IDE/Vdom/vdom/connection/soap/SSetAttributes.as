package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	public class SSetAttributes extends EventDispatcher 
	{	
		private static 	var instance:SSetAttributes;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetAttributes() 
		{	
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.set_attributes.addEventListener(ResultEvent.RESULT,completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SSetAttributes 
		{
//			if (!instance)
				instance = new SSetAttributes();
	
			return instance;
		}
		
		public function execute(appid:String = '', objid:String = '', attr:String = ''):String
		{
			// protect
			var sid:String = code.sessionId;		// - идентификатор сессии 
			var skey:String = code.skey();			//- очередной ключ сессии 
			
			//send data & set listener 
			ws.set_attributes(sid, skey, appid, objid, attr);
			
			
			return skey;
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
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_S_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.SET_ATTRIBUTE_S_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}