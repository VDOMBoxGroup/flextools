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
		
		public function execute(appid:String, objid:String, parentid:String, sdynamic:String ):void{
			// protect
			ws.render_wysiwyg.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.render_wysiwyg.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.render_wysiwyg.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.render_wysiwyg.arguments.objid  	= objid;		//- идентификатор объекта 
			ws.render_wysiwyg.arguments.parentid  	= parentid;
			ws.render_wysiwyg.arguments.dynamic  = sdynamic;		//- способ рендеринга: для только что созданных объектов нужно указывать 0, для всех остальных 1
			
			//send data & set listener 
			ws.render_wysiwyg();
			ws.render_wysiwyg.addEventListener(ResultEvent.RESULT,completeListener);
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
				resultXML = resultXML.Result[0];
				evt = new SoapEvent(SoapEvent.RENDER_WYSIWYG_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}