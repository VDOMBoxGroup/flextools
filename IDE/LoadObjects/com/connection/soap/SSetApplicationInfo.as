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
	
	public class SSetApplicationInfo extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetApplicationInfo(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, attrname:String, attrvalue:String ):void{
			// data
			ws.set_application_info.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_application_info.arguments.skey 		= code.skey();	//- очередной ключ сессии 
			ws.set_application_info.arguments.appid  	= appid;		//- идентификатор приложения;
			ws.set_application_info.arguments.attrname 	= attrname;		//- имя атрибута приложения из раздела information
			ws.set_application_info.arguments.attrvalue = attrvalue;	//- значение атрибута
			
			//send data & set listener 
			ws.set_application_info();
			ws.set_application_info.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.set_application_info.lastResult.Result);
			var evt:SoapEvent;
			
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.SET_APLICATION_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				//trace("ERROR! From: " + this.toString() )
			} else{

				evt = new SoapEvent(SoapEvent.SET_APLICATION_OK);
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