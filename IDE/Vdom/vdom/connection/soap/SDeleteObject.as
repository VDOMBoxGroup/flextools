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
	
	public class SDeleteObject extends EventDispatcher 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SDeleteObject(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( appid:String = '', objid:String = '' ):void{
			// data
			ws.delete_object.arguments.sid 			= code.sessionId; 		// - идентификатор сессии 
			ws.delete_object.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.delete_object.arguments.appid  		= appid;				//- идентификатор приложения 
			ws.delete_object.arguments.objid  		= objid;				//- идентификатор объекта
			
			//send data & set listener 
			ws.delete_object();
			ws.delete_object.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.delete_object.lastResult.Result);
			var evt:SoapEvent;
			
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				evt = new SoapEvent(SoapEvent.DELETE_OBJECT_ERROR);
				evt.result = resultXML;
				dispatchEvent(evt);
			//	Alert.show("ERROR!\nFrom: " + this.toString() )
			//	trace("ERROR! From: " + this.toString() );
			} else{

				evt = new SoapEvent(SoapEvent.DELETE_OBJECT_OK);
				evt.result = resultXML;
				dispatchEvent(evt);
			//	trace(this.toString() + ' - OK')
			}
		}
		
		public    function getResult():XML{
			return resultXML;
		}
	}
}