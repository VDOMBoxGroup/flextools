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
	
	public class SListApplications extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SListApplications(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void
		{
			// protect
			ws.list_applications.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.list_applications.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			//send data & set listener 
			ws.list_applications();
			ws.list_applications.addEventListener(ResultEvent.RESULT,completeListener);	
		}
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.list_applications.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
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