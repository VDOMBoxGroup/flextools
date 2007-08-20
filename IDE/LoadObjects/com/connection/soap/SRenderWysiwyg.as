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
	
	public class SRenderWysiwyg extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SRenderWysiwyg(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute(appid:String, objid:String, dynamic:String):void{
			// data
			ws.render_wysiwyg.arguments.sid 		= code.sessionId;		// - идентификатор сессии 
			ws.render_wysiwyg.arguments.skey 		= code.skey();			//- очередной ключ сессии 
			ws.render_wysiwyg.arguments.appid  	= appid;		//- идентификатор приложения 
			ws.render_wysiwyg.arguments.objid  	= objid;		//- идентификатор объекта 
			ws.render_wysiwyg.arguments.dynamic  = dynamic;		//- способ рендеринга: для только что созданных объектов нужно указывать 0, для всех остальных 1
		
			
			//send data & set listener 
			ws.render_wysiwyg();
			ws.render_wysiwyg.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			// get result 
			resultXML = XML(ws.render_wysiwyg.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){

				dispatch(new Event(RENDER_WYSIWYG_ERROR));
				// Alert.show("ERROR!\nFrom: " + this.toString() )
				trace("ERROR! From: " + this.toString() )
			} else{

				dispatch(new Event(RENDER_WYSIWYG_OK));
				//trace(this.toString() + ' - OK')
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}