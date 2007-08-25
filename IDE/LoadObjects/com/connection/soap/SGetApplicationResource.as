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
	
	public class SGetApplicationResource extends EventDispatcher
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, resid:String ):void
		{
			// protect
			ws.get_application_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_application_resource.arguments.skey 		= code.skey();			//- очередной ключ сессии 
		
			// data
			ws.get_application_resource.arguments.appid 	= appid;				//- идентификатор приложения
			ws.get_application_resource.arguments.resid  	= resid;				//- идентификатор ресурса
			
			//send data & set listener 
			ws.get_application_resource();
			ws.get_application_resource.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_application_resource.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_RESOURCE_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_APPLICATION_RESOURCE_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
			}
		}
	}
}