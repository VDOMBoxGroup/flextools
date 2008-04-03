package vdom.connection.soap
{
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import vdom.connection.protect.Code;
	
	
	public class SRenderWysiwyg extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SRenderWysiwyg(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String, parentid:String, sdynamic:String ):String {
			// protect
			var sid:String 		= code.sessionId;		// - идентификатор сессии 
			var skey:String		= code.skey();			//- очередной ключ сессии 
			
			//send data & set listener
			ws.render_wysiwyg.addEventListener(ResultEvent.RESULT,completeListener); 
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
			
			resultXML = <Result>{XMLList(event.result)}</Result>;
			//resultXML = resultXML.Objects[0];
			var evt:SoapEvent;
			// check Error
			if(resultXML.Error.length() > 0)
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