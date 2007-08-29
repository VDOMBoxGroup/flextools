package vdom
{
	import mx.rpc.soap.WebService;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import com.gsolo.encryption.MD5;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import com.connection.soap.Soap;
	import com.connection.soap.SoapEvent;
	import vdom.events.AuthEvent;
	
	public class Auth 
		implements IEventDispatcher
	{
		private var soap:Soap;
		
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
			addEventListener(AuthEvent.AUTH_COMPLETE, authCompleteListener);
			addEventListener(AuthEvent.AUTH_ERROR, authCompleteListener);
			
			var _appId:String = '26c0dc2d-5edd-44ae-aaa9-195f54c46f74';
			var _pageId:String = 'acc9e168-8b68-49e3-a9f7-c355e7b5a016';
			
			soap = Soap.getInstance();		
		}

		public function login(login:String, password:String):void {
			
			soap.login(login, password);
			soap.addEventListener(SoapEvent.LOGIN_OK, loginHandler);
		}
		
		private function loginHandler(event:SoapEvent):void {
			dispatchEvent(new Event('authComplete'));
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