package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SRenderWysiwyg extends EventDispatcher
	{
		private static 	var instance:SRenderWysiwyg;
		
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SRenderWysiwyg() 
		{	
	 		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	 		ws = Soap.ws;
	 		ws.render_wysiwyg.addEventListener(ResultEvent.RESULT, completeListener); 
 
		} 		
		 
		 // initialization		
		public static function getInstance():SRenderWysiwyg 
		{
			if (!instance)
				instance = new SRenderWysiwyg();
	
			return instance;
		}
		
		public function execute(appid:String, objid:String, parentid:String, sdynamic:String ):String {
			// protect
			var sid:String 		= code.sessionId;		// - идентификатор сессии 
			var skey:String		= code.skey();			//- очередной ключ сессии 
			
			//send data & set listener
			
			ws.render_wysiwyg(
				sid,
				skey,
				appid,
				objid,
				parentid,
				sdynamic
			);
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
				evt = new SoapEvent(SoapEvent.RENDER_WYSIWYG_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.RENDER_WYSIWYG_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}