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
	
	public class SGetAllTypes extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetAllTypes(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void
		{
			// protect
			ws.get_all_types.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_all_types.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			// no data to send
			
			//send data & set listener 
			ws.get_all_types();
			ws.get_all_types.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.get_all_types.lastResult.Result);
			var evt:SoapEvent;

			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.GET_ALL_TYPES_ERROR,resultXML );
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.GET_ALL_TYPES_OK, resultXML);
				dispatchEvent(evt);
			}
		}
	}
}
	