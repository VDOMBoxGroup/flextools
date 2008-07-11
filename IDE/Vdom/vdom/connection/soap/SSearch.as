package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SSearch extends EventDispatcher 
	{
		private static 	var instance:SSearch;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSearch() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.search.addEventListener(ResultEvent.RESULT,completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SSearch 
		{
			if (!instance)
				instance = new SSearch();
	
			return instance;
		}
		
		public function execute(appid:String, pattern:String):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			//send data & set listener 
			ws.search(sid, skey, appid, pattern);
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
				evt = new SoapEvent(SoapEvent.SEARCH_ERROR, resultXML);
				dispatchEvent(evt);
				trace(event.result);
			} else{
				evt = new SoapEvent(SoapEvent.SEARCH_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}