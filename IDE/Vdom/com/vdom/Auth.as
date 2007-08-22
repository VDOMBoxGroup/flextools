package com.vdom
{
	import mx.rpc.soap.WebService;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import com.gsolo.encryption.MD5;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	[Event(name="authComplete", type="flash.events.Event")]
	[Event(name="authError", type="flash.events.Event")]
	
	
	public class Auth 
		implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		private var ws:WebService;
		private var _login:String;
		private var _password:String;
		private var _count:Number;
		public var SID:String;
		[Bindable]
		public var loginName:String;
				
		public function Auth() {
			dispatcher = new EventDispatcher(this);
			addEventListener("authComplete", authCompleteListener);
			addEventListener("authError", authCompleteListener);
			ws = new WebService();
			ws.wsdl = 'http://seg.tsu.ru:81/vdom.wsdl';
			ws.destination = 'login';
			ws.useProxy = false;		
			
		}

		public function login(login:String, password:String):void {
			_login = loginName = login;
			_password = password;
			ws.login.arguments.name = _login;
			ws.login.arguments.hash_str = '';
			_count = 1;
			ws.addEventListener("fault", faultHandler);
			ws.login.addEventListener("result", resultHandler);
			ws.loadWSDL();
			ws.login();
		}

      

        private function authCompleteListener(eventObj:Event):void {
            // Handle event.
        }
		
		public function resultHandler(event:ResultEvent):void{
			if (_count == 1) {
				ws.login.arguments.hash_str = MD5.encrypt(ws.login.lastResult.Result+_password);
				_count = 2;
				ws.login();
			}else if (_count == 2) {
				if (ws.login.lastResult.Result != 'Error') {
					SID = ws.login.lastResult.Result;
					dispatchEvent(new Event("authComplete"));
				} else {
					dispatchEvent(new Event("authError"));
				}
			}
		}
		
		public function faultHandler(event:FaultEvent):void{
			trace (event);	
		}
                    
	    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
	        dispatcher.addEventListener(type, listener, useCapture, priority);
	    }
	           
	    public function dispatchEvent(evt:Event):Boolean{
	        return dispatcher.dispatchEvent(evt);
	    }
	    
	    public function hasEventListener(type:String):Boolean{
	        return dispatcher.hasEventListener(type);
	    }
	    
	    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
	        dispatcher.removeEventListener(type, listener, useCapture);
	    }
	                   
	    public function willTrigger(type:String):Boolean {
	        return dispatcher.willTrigger(type);
	    }
	}

}