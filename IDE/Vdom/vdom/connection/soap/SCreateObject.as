package vdom.connection.soap
{
	import mx.rpc.soap.WebService;
	import flash.events.EventDispatcher;
	import vdom.connection.protect.Code;
	import mx.rpc.events.ResultEvent;
	
	
	public class SCreateObject extends EventDispatcher
	{
		private static 	var instance:SCreateObject;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateObject() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.create_object.addEventListener(ResultEvent.RESULT,completeListener);
 
		} 		
		 
		 // initialization		
		public static function getInstance():SCreateObject 
		{
			if (!instance)
				instance = new SCreateObject();
	
			return instance;
		}
		
		public function execute(appid:String='',parentid:String='',typeid:String = '', attrs:String = '', name:String =''):void
		{
			// protect
			var sid:String			= code.sessionId;		// - идентификатор сессии 
			var skey:String  		= code.skey();	//- очередной ключ сессии 
			
			
			//send data & set listener 
			ws.create_object(sid, skey, appid, parentid, typeid, name, attrs);
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
				evt = new SoapEvent(SoapEvent.CREATE_OBJECT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.CREATE_OBJECT_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}