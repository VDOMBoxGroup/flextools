package vdom.managers
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import vdom.connection.NewSOAP;
import vdom.connection.soap.SoapEvent;
import vdom.events.AuthenticationEvent;

public class AuthenticationManager implements IEventDispatcher
{	
	private static var instance:AuthenticationManager;
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	private var newSoap:NewSOAP = NewSOAP.getInstance();
	
	private var _username:String;
//	private var _tmpUsername:String;
	
	private var _password:String;
//	private var _tmpPassword:String;
	
	private var _hostname:String;
	
	
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
	public function AuthenticationManager()
	{	
		if (instance)
			throw new Error("Instance already exists.");
	}
	
	[Bindable]
	public function get username():String
	{
		return _username;
	}
	
	public function set username(value:String):void
	{
		_username = value;
	}
	
	public function get password():String
	{
		return _password;
	}
	
	public function get hostname():String
	{
		return _hostname;
	}
	
	public function login(hostname:String, username:String, password:String):void {
		
		newSoap.addEventListener(SoapEvent.LOGIN_OK, soap_loginOKHandler);
		newSoap.addEventListener(SoapEvent.LOGIN_ERROR, soap_loginErrorHandler);
		
		_hostname = hostname;
		_username = username;
		newSoap.login(username, password);
	}
	
	public function logout():void {
		
		_username = _password = null;
	}
	
	private function soap_loginOKHandler(event:SoapEvent):void {
		
		_username = event.result.Username;
		
		newSoap.removeEventListener(SoapEvent.LOGIN_OK, soap_loginOKHandler);
		
		dispatchEvent(new Event(AuthenticationEvent.LOGIN_COMPLETE));
	}
	
	private function soap_loginErrorHandler(event:SoapEvent):void {
		
		newSoap.removeEventListener(SoapEvent.LOGIN_ERROR, soap_loginErrorHandler);
		dispatchEvent(new Event(AuthenticationEvent.LOGIN_ERROR));
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