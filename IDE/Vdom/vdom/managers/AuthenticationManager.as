package vdom.managers {
	
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.AuthenticationEvent;

public class AuthenticationManager implements IEventDispatcher {
	
	private static var instance:AuthenticationManager;
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	private var publicData:Object;
	private var soap:Soap;
	
	private var _username:String;
	private var _tmpUsername:String;
	
	private var _password:String;
	private var _tmpPassword:String;
	
	private var _ip:String;
	
	
	/**
	 * 
	 * @return instance of DataManager class (Singleton)
	 * 
	 */	
	public static function getInstance():AuthenticationManager
	{
		if (!instance) {
			
			instance = new AuthenticationManager();
		}

		return instance;
	}
	
	/**
	 * 
	 * Constructor
	 * 
	 */	
	public function AuthenticationManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		//publicData = mx.core.Application.application.publicData;
		
	}
	
	public function changeAuthenticationInformation(username:String, password:String, ip:String):void {
		
		_tmpUsername = username;
		_tmpPassword = password;
		_ip = ip;
	}
	
	public function login():void {
		
		var wsdl:String= 'http://'+_ip+'/vdom.wsdl';
		soap.addEventListener('loadWsdlComplete', soapInitComplete);
		soap.init(wsdl);
	}
	
	public function logout():void {
		
		_username = _password = null;
		
		var event:AuthenticationEvent = new AuthenticationEvent(AuthenticationEvent.LOGOUT)
		dispatcher.dispatchEvent(event);
	}
	
	public function get username():String {
		
		return _username;
	}
	
	public function get password():String {
		
		return _password;
	}
	
	public function get ip():String {
		
		return _ip;
	}
	
	private function soapInitComplete(event:Event):void {
		
		soap.removeEventListener('loadWsdlComplete', soapInitComplete);
		
		soap.addEventListener(SoapEvent.LOGIN_OK, loginHandler);
		soap.addEventListener(SoapEvent.LOGIN_ERROR, loginErrorHandler);
		
		soap.login(_tmpUsername, _tmpPassword);
	}
	
	private function loginHandler(event:SoapEvent):void {
		
		_username = _tmpUsername;
		_password = _tmpPassword;
		
		soap.removeEventListener(SoapEvent.LOGIN_OK, loginHandler);
		dispatchEvent(new Event(AuthenticationEvent.LOGIN_COMPLETE));
	}
	
	private function loginErrorHandler(event:SoapEvent):void {
		
		trace('error! \r\n');
		trace(event.result);
	}
	
	// Реализация диспатчера
	
	/**
     *  @private
     */
	public function addEventListener(
		type:String, 
		listener:Function, 
		useCapture:Boolean = false, 
		priority:int = 0, 
		useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority);
    }
    
    /**
     *  @private
     */
    public function dispatchEvent(evt:Event):Boolean{
        return dispatcher.dispatchEvent(evt);
    }
    
	/**
     *  @private
     */
    public function hasEventListener(type:String):Boolean{
        return dispatcher.hasEventListener(type);
    }
    
	/**
     *  @private
     */
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
        dispatcher.removeEventListener(type, listener, useCapture);
    }
    
    /**
     *  @private
     */            
    public function willTrigger(type:String):Boolean {
        return dispatcher.willTrigger(type);
    }
}
}