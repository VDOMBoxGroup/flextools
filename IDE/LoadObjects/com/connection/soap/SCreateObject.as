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
	
	public class SCreateObject extends EventDispatcher
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SCreateObject(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String='',parentid:String='',typeid:String = ''):void
		{
			// protect
			ws.create_object.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.create_object.arguments.skey 	= code.skey(); 			//- очередной ключ сессии 
			
			// data
			ws.create_object.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.create_object.arguments.parentid = parentid;		//- идентификатор объекта 
			ws.create_object.arguments.typeid  	= typeid;		//- идентификатор типа
			
			//send data & set listener 
			ws.create_object();
			ws.create_object.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void
		{
			// get result 
			resultXML = XML(ws.create_object.lastResult.Result);
			var evt:SoapEvent;
			
			// check Error
			if(resultXML.name().toString() == 'Error')
			{
				evt = new SoapEvent(SoapEvent.CREATE_OBJECT_ERROR, resultXML);
				dispatchEvent(evt);
			} else{
				evt = new SoapEvent(SoapEvent.CREATE_OBJECT_OK,resultXML);
				dispatchEvent(evt);
			}
		}
	}
}