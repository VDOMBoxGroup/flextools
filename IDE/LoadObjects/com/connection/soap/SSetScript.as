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
	
	public class SSetScript extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SSetScript(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String,objid:String, script:String ):void{
			// data
			ws.set_script.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.set_script.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.set_script.arguments.appid  		= appid;		//- идентификатор приложения 
			ws.set_script.arguments.objid  		= objid;		//- идентификатор объекта
			ws.set_script.arguments.script  	= script;		//- текст скрипта 
			
			//send data & set listener 
			ws.set_script();
			ws.set_script.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.set_script.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(SET_SCRIPT_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(SET_SCRIPT_OK));
				trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}