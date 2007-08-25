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
	
	public class SGetTopObjects extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetTopObjects(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String):void
		{
			// protect
			ws.get_top_objects.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_top_objects.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// data
			ws.get_top_objects.arguments.appid  	= appid;		//- идентификатор приложения 
			
			//send data & set listener 
			ws.get_top_objects();
			ws.get_top_objects.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_top_objects.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				evt = new SoapEvent(SoapEvent.GET_TOP_OBJECTS_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_TOP_OBJECTS_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}