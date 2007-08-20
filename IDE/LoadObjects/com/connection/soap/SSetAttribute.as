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
	
	public class SSetAttribute extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetAttribute(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String,objid:String, attr:String, value:String):void{
			// data
			ws.set_attribute.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_attribute.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.set_attribute.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.set_attribute.arguments.objid  	= objid;		//- идентификатор объекта
			ws.set_attribute.arguments.attr  	= attr;			//- имя атрибута  
			ws.set_attribute.arguments.value 	= value;		//- значение атрибута
			
			//send data & set listener 
			ws.set_attribute();
			ws.set_attribute.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.set_attribute.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(SET_ATTRIBUTE_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(SET_ATTRIBUTE_OK));
				//trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}