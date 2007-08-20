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
	
	public class SListTypes extends SoapEvent 
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
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				dispatch(new Event(LIST_TYPES_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(LIST_TYPES_OK));
				//trace(this.toString() + ' - OK');
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}