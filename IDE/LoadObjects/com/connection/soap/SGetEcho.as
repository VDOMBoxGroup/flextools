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
	
	public class SGetEcho extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetEcho():void{
		}
		
		public function execute(ws:WebService):void{

			this.ws = ws;

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
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(GET_ECHO_ERROR));
			//	Alert.show("GetEcho: "+resultXML);
			} else{
			
				dispatch(new Event(GET_ECHO_OK));
				//Alert.show("GetEcho: "+resultXML); 
				trace ("SGetEcho.as: OK");
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}