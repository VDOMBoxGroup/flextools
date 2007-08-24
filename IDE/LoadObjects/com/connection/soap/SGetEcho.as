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
	
	public class SGetEcho extends EventDispatcher
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetEcho(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute():void{

			// data
			ws.get_echo.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			
			//send data & set listener 
			ws.get_echo();
			ws.get_echo.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			ws.get_echo.removeEventListener(ResultEvent.RESULT,completeListener);

			// get result 
			resultXML = XML(ws.get_echo.lastResult.Result);
			var evt:SoapEvent;
			
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.GET_ECHO_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
			//	Alert.show("GetEcho: "+resultXML);
			} else{
				evt = new SoapEvent(SoapEvent.GET_ECHO_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
				//Alert.show("GetEcho: "+resultXML); 
				//trace ("SGetEcho.as: OK");
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}