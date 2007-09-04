package vdom {

import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.IEventDispatcher;
import mx.rpc.soap.WebService;
import mx.rpc.events.ResultEvent;
import mx.rpc.events.FaultEvent;

import vdom.events.AuthEvent;
import vdom.connection.soap.SoapEvent;
import vdom.connection.soap.Soap;
	
public class Auth implements IEventDispatcher {
	
	[Bindable]
	public var loginName:String;
	
	private var soap:Soap;
	private var dispatcher:EventDispatcher;
	private var ws:WebService;
	private var _login:String;
	private var _password:String;
	private var _count:Number;
	public var SID:String;
	
	/**
	 * 
	 * Класс, реализующий авторизацию.
	 * 
	 */		
	public function Auth() {
		
		soap = Soap.getInstance();
		
		dispatcher = new EventDispatcher(this);
		
		addEventListener(AuthEvent.AUTH_COMPLETE, authCompleteListener);
		addEventListener(AuthEvent.AUTH_ERROR, authErrorListener);		
	}
	
	/**
	 * Попытка аутентификации.
	 * @param login - логин пользователя.
	 * @param password - пароль пользователя
	 * 
	 */	
	public function login(login:String, password:String):void {
		
		soap.addEventListener(SoapEvent.LOGIN_OK, loginHandler);
		soap.addEventListener(SoapEvent.LOGIN_ERROR, loginErrorHandler);
		soap.login(login, password);
	}
	
	/**
     *  @private
     */
	private function loginHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.LOGIN_OK, loginHandler);
		dispatchEvent(new Event(AuthEvent.AUTH_COMPLETE));
	}
	
	/**
     *  @private
     */
	private function loginErrorHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.LOGIN_ERROR, loginErrorHandler);
		dispatchEvent(new Event(AuthEvent.AUTH_ERROR));
	}
	
	/**
     *  @private
     */
    private function authCompleteListener(eventObj:Event):void {
        // Handle event.
    }
    
    /**
     *  @private
     */
    private function authErrorListener(eventObj:Event):void {
        // Handle event.
    }
	
	// Реализация диспатчера
	/**
     *  @private
     */
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
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