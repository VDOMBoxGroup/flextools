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
	
	public class SSetResource extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetResource(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, resid:String, restype:String, resname:String, resdata:String  ):void{
			// data
			ws.set_resource.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_resource.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.set_resource.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_resource.arguments.restype  	= restype;		//- идентификатор приложения 
			ws.set_resource.arguments.resname  	= resname;		//- идентификатор приложения 
			ws.set_resource.arguments.resid  	= resid;		//- идентификатор ресурса: необходимо указывать для изменения существующего ресурса; 
																	// для добавления нового - пустая строка
			ws.set_resource.arguments.resdata  	= resdata;		//- текст скрипта 
		//		
		//resname
			//send data & set listener 
		//	Alert.show('set_resource - send');
			ws.set_resource();
			ws.set_resource.addEventListener(ResultEvent.RESULT,completeListener);
			
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.set_resource.lastResult.Result);
			var evt:SoapEvent;
			Alert.show('set_resource - result');
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.SET_RESOURCE_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
				 //Alert.show("ERROR!\nFrom: " + this.toString() )
				//trace("ERROR! From: " + this.toString() )
			} else{

				evt = new SoapEvent(SoapEvent.SET_RESOURCE_OK);
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