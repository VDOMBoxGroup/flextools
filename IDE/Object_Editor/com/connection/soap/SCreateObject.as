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
	
	public class SCreateObject extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateObject():void{
		}
		
		public function execute(ws:WebService, appid:String='NaN',parentid:String='NaN',typeid:String = 'NaN'):void{

			this.ws = ws;

			// data
			ws.create_object.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.create_object.arguments.skey 	= code.skey(); 	//- очередной ключ сессии 
			ws.create_object.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.create_object.arguments.parentid = parentid;		//- идентификатор объекта 
			ws.create_object.arguments.typeid  	= typeid;		//- идентификатор типа
			
			//send data & set listener 
			ws.create_object();
			ws.create_object.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.create_object.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event( CREATE_OBJECT_ERROR));
				Alert.show("ERROR!\nFrom: " + this.toString() )
			} else{
				dispatch(new Event(CREATE_OBJECT_OK));
				trace(resultXML.toString());
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}