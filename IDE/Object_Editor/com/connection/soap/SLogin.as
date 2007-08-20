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
	
	public class SLogin extends SoapEvent 
	{
		private var ws			:WebService;
		private var resultXML	:XML;
		private var code		:Code =  Code.getInstance();
   
		public function SLogin(ws:WebService):void{
			this.ws = ws;
		}
		
		public function execute( login:String, password:String):void{

			
			ws.open_session.arguments.name 		= login; 				 //- имя пользователя, строка
			ws.open_session.arguments.pwd_md5 	= MD5.encrypt(password); //- md5-хэш пароля, строка
			
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,completeListener);
		}
		
		
		private  function completeListener(event:ResultEvent):void{
			
			resultXML = XML(ws.open_session.lastResult.Result);
			
			// check Error
			if(resultXML.name().toString() == 'Error'){
				Alert.show("ERROR!\nFrom: " + this.toString() )
			} else{
				
				// run session protector
				code.init(resultXML.HashString);
				code.inputSKey(resultXML.SessionKey);  
				code.sessionId = resultXML.SessionId;
		
			//	Alert.show("Password and User correct\nsid: "+ code.sessionId );
			trace("Password and User correct\nsid: "+ code.sessionId);
			trace(this.toString());
				dispatch(new Event(LOGIN_OK));
			}
		}
		
		public override   function getResult():XML{
			return resultXML;
		}
	}
}