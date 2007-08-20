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
	
	public class SGetApplicationResource extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetApplicationResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, resid:String ):void{
			// data
			ws.get_application_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_application_resource.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			ws.get_application_resource.arguments.appid 	= appid;				//- идентификатор приложения
			ws.get_application_resource.arguments.resid  	= resid;				//- идентификатор ресурса
			
			//send data & set listener 
			ws.get_application_resource();
			ws.get_application_resource.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.get_application_resource.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(GET_APPLICATION_RESOURCE_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(GET_APPLICATION_RESOURCE_OK));
				//	trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}