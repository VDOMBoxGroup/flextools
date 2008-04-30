package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	public class SListResources extends EventDispatcher
	{
		private static 	var instance:SListResources;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SListResources() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.list_resources.addEventListener(ResultEvent.RESULT,completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SListResources 
		{
			if (!instance)
				instance = new SListResources();
	
			return instance;
		}
		
		public function execute(ownerid:String = ''):void
		{
			//  protect
			var sid:String = code.sessionId;		// - идентификатор сессии 
			var skey:String = code.skey();	//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.list_resources(sid, skey, ownerid);
			
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
				evt = new SoapEvent(SoapEvent.LIST_RESOURSES_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.LIST_RESOURSES_OK, resultXML);
				dispatchEvent(evt);
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}