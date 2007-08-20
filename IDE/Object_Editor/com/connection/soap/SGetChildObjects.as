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
	
	public class SGetChildObjects extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetChildObjects(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(ws:WebService):void{
			// data
			ws.XXXX_XXX.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.XXXX_XXX.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			//send data & set listener 
			ws.XXXX_XXX();
			ws.XXXX_XXX.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.XXXX_XXX.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(YYYYY_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(YYYYY_OK));
				trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}