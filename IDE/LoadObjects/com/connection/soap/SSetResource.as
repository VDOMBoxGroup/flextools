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
	
	public class SSetResource extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, resid:String, resdata:String  ):void{
			// data
			ws.set_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_resource.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.set_resource.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_resource.arguments.resid  	= resid;		//- идентификатор ресурса: необходимо указывать для изменения существующего ресурса; 
																	// для добавления нового - пустая строка
			ws.set_resource.arguments.resdata  	= resdata;		//- текст скрипта 
			
			//send data & set listener 
			ws.set_resource();
			ws.set_resource.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.set_resource.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(SET_RESOURCE_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(SET_RESOURCE_OK));
				trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}