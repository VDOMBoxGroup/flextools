package com.vdom.connect
{

	import mx.rpc.soap.WebService;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.AbstractEvent;
	import com.gsolo.encryption.MD5;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import mx.controls.Alert;
	import com.gsolo.encryption.Code;
	
	public class Soap 
	{
		private var code:Code;
		private var dispatcher:EventDispatcher;
		private var ws:WebService = new WebService;
		
		// initialization
		public function Soap():void {
			ws.wsdl = 'http://192.168.0.23:82/vdom.wsdl';
			ws.useProxy = false;
			ws.loadWSDL();		
			ws.addEventListener(FaultEvent.FAULT, errorListener);
		}
		
		// 1 - open_session
		public function login(login:String, password:String):void {
			ws.open_session.arguments.name = login;
			ws.open_session.arguments.pwd_md5 = MD5.encrypt(password);
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,loginCompleteListener);
		}

		private function loginCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.open_session.lastResult.Result);
			// run session protector
			code = new Code(myXML.HashString);
			code.inputSKey(myXML.SessionKey);
			
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("Password and User correct" );
				ws.open_session.removeEventListener(ResultEvent.RESULT,loginCompleteListener);
			}
		}	
		
		// 2 - close_session
		public function closeSession():void {
			ws.close_session.arguments.sid = code.skey();
			ws.close_session();
			ws.close_session.addEventListener(ResultEvent.RESULT,closeSessionCompleteListener);	
		}

		private function closeSessionCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.close_session.lastResult.Result);
			if(myXML.Error.toString() != ''){
				Alert.show("Error from server:\n" + myXML.Error );
			} else{
				Alert.show("Сессия закрыта: " + myXML);
				ws.close_session.removeEventListener(ResultEvent.RESULT,closeSessionCompleteListener);
			}
			Alert.show("Сессия закрыта: " + myXML);
		}
		
		
		// 3 - create application
		
		// 4 - set application general information
		// 5 - get the list of all applications 
		// 6 - get the list of all types 
		// 7 - get type description 
		// 8 - get type resource
		//Error
		private function errorListener(event:FaultEvent):void{
			Alert.show("Error:\n"+ event);
		}	
	}
}