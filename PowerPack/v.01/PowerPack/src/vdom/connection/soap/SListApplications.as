package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SListApplications extends EventDispatcher 
	{
		private static 	var instance:SListApplications;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SListApplications() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.list_applications.addEventListener(ResultEvent.RESULT, completeListener);	
 
		} 		
		 
		 // initialization		
		public static function getInstance():SListApplications 
		{
			if (!instance)
				instance = new SListApplications();
	
			return instance;
		}
		
		public function execute():void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			ws.list_applications(sid, skey);
		}
		
		private  function completeListener(event:ResultEvent):void
		{
			
			resultXML = new XML(<Result />);
			resultXML.appendChild(XMLList(event.result));
			
			// old
			//resultXML = <Result>{XMLList(event.result)}</Result>;
			//resultXML = resultXML.Applications[0];

			var evt:SoapEvent;
			var res:String = resultXML.Error;
			// check Error
			if(res != '')
			{
				evt = new SoapEvent(SoapEvent.LIST_APLICATION_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.LIST_APLICATION_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}