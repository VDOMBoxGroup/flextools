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
	
	public class SGetChildObjects extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SGetChildObjects(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String):void{
			// data
			ws.get_child_objects.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.get_child_objects.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			
			ws.get_child_objects.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.get_child_objects.arguments.objid  	= objid;		//- идентификатор объекта 
			
			//send data & set listener 
			ws.get_child_objects();
			ws.get_child_objects.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.get_child_objects.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(GET_CHILD_OBJECTS_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(GET_CHILD_OBJECTS_OK));
				trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}