package com.connection.soap
{
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.profiler.showRedrawRegions;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import mx.controls.Alert;
	import mx.preloaders.DownloadProgressBar;
	import com.connection.protect.*;
	
	public class SRenderWysiwyg extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SRenderWysiwyg(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String, sdynamic:String ):void{
			// protect
			ws.render_wysiwyg.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.render_wysiwyg.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.render_wysiwyg.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.render_wysiwyg.arguments.objid  	= objid;		//- идентификатор объекта 
			ws.render_wysiwyg.arguments.dynamic  = sdynamic;		//- способ рендеринга: для только что созданных объектов нужно указывать 0, для всех остальных 1
			
			//send data & set listener 
			ws.render_wysiwyg();
			ws.render_wysiwyg.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			resultXML = XML(ws.render_wysiwyg.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
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