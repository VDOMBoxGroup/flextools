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
	
	public class SGetApplicationLanguageData extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationLanguageData(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String):void{

			

			// data
			ws.get_application_language_data.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_application_language_data.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.get_application_language_data.arguments.appid  	= appid;		//- идентификатор приложения 
			
			//send data & set listener 
			ws.get_application_language_data();
			ws.get_application_language_data.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.get_application_language_data.lastResult.Result);
			var evt:SoapEvent;
			
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				//trace("ERROR! From: " + this.toString() )
			} else{

				evt = new SoapEvent(SoapEvent.GET_APPLICATION_LANGUAGE_DATA_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
				//trace(this.toString() + ' - OK')
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}