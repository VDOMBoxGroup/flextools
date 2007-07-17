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
	
	public class Soap 
	{
		private var dispatcher:EventDispatcher;
		private var ws:WebService = new WebService;
		
		// initialization
		public function Soap():void {
			ws.wsdl = 'http://192.168.0.23:82/vdom.wsdl';
			ws.useProxy = false;
			ws.loadWSDL();		
			ws.addEventListener(FaultEvent.FAULT, errorListener);
		}
		
		// open_session
		public function login(login:String, password:String):void {
			ws.open_session.arguments.name = login;
			ws.open_session.arguments.pwd_md5 = MD5.encrypt(password);
			ws.open_session();
			ws.open_session.addEventListener(ResultEvent.RESULT,authCompleteListener);
		}

		private function authCompleteListener(event:ResultEvent):void{
			var myXML:XML = XML(ws.open_session.lastResult.Result);
			Alert.show("Сессия открыта: " + myXML);
			ws.open_session.removeEventListener(ResultEvent.RESULT,authCompleteListener);
		}	
		
		//close_session
		public function close_session():void {
			ws.close_session.arguments.sid = '123';
			ws.close_session();
			ws.addEventListener(ResultEvent.RESULT,authCompleteListenera);	
		}

		private function authCompleteListenera(event:ResultEvent):void{
			var myXML:XML = XML(ws.close_session.lastResult.Result);
			Alert.show("Сессия закрыта: " + myXML);
		}
		
		//Error
		private function errorListener(event:FaultEvent):void{
			Alert.show("Error:\n"+ event);
		}	
	}
}