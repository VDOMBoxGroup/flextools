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
	
	public class SListTypes extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SListTypes(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void{
			// data
			ws.list_types.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.list_types.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			//send data & set listener 
			ws.list_types();
			ws.list_types.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.list_types.lastResult.Result);
			var evt:SoapEvent;
			
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				evt = new SoapEvent(SoapEvent.LIST_TYPES_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				//trace("ERROR! From: " + this.toString() )
			} else{

				evt = new SoapEvent(SoapEvent.LIST_TYPES_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
				//trace(this.toString() + ' - OK');
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}