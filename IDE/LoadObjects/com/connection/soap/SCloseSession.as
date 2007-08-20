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
	
	public class SCloseSession extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCloseSession(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void{
			// data
			ws.close_session.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			
			//send data & set listener 
			ws.close_session();
			ws.close_session.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.close_session.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(CLOSE_SESSION_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(CLOSE_SESSION_OK));
				trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}