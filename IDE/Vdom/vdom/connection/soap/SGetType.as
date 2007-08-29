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
	
	public class SGetType extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetType(ws:WebService):void{
				this.ws = ws;
		}
		
		public function execute(typeid:String):void{
			// data
			ws.get_type.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_type.arguments.skey 		= code.skey();			//- очередной ключ сессии
			ws.get_type.arguments.typeid  	= typeid;		//- идентификатор типа 
			
			//send data & set listener 
			ws.get_type();
			ws.get_type.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.get_type.lastResult.Result);
			var evt:SoapEvent;
			
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.GET_TYPE_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				//trace("ERROR! From: " + this.toString() )
			} else{
				evt = new SoapEvent(SoapEvent.GET_TYPE_OK);
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