package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SWholeUpdate extends EventDispatcher 
	{
		private static 	var instance:SWholeUpdate;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SWholeUpdate() 
		{	
//	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.whole_update.addEventListener(ResultEvent.RESULT,completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SWholeUpdate 
		{
//			if (!instance)
				instance = new SWholeUpdate();
	
			return instance;
		}
		
		public function execute(appid:String, objid:String, data:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.whole_update(sid, skey, appid, objid, data);
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
				evt = new SoapEvent(SoapEvent.WHOLE_UPDATE_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.WHOLE_UPDATE_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}