package vdom.connection
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.soap.LoadEvent;
import mx.rpc.soap.WebService;

import vdom.connection.protect.Code;
import vdom.connection.protect.MD5;
import vdom.connection.soap.SoapEvent;

public dynamic class NewSOAP extends Proxy implements IEventDispatcher
{
	private static var instance:NewSOAP;
	
	private var ws:WebService;
	private var dispatcher:EventDispatcher = new EventDispatcher();
	
	private var code:Code =  Code.getInstance();
	
	private var resourceManager:IResourceManager = 
	 									ResourceManager.getInstance();
	
	public function NewSOAP()
	{
		if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
	}
	
	public static function getInstance():NewSOAP
	{
		if (!instance)
			instance = new NewSOAP();

		return instance;
	}
	
	public function init(wsdl:String):void
	{
		ws = new WebService();
		ws.wsdl = wsdl;
		ws.useProxy = false;
		ws.addEventListener(LoadEvent.LOAD, loadHandler);
		ws.addEventListener(FaultEvent.FAULT, faultHandler);
		ws.loadWSDL();
	}
	
	public function login(login:String, password:String):*
	{
		var password:String = MD5.encrypt(password);
		
		ws.open_session.addEventListener(ResultEvent.RESULT, loginHandler);	
		ws.open_session(login, password);
	}
	
	override flash_proxy function getProperty(name:*):*
	{
		var functionName:String = getLocalName(name);
		var operation:* = ws[functionName];
		
		if(functionName && operation)
			return operation;
		else
			return null;
//		 
	}
	
	override flash_proxy function setProperty(name:*, value:*):void
	{
		var message:String = resourceManager.getString(
            "rpc", "operationsNotAllowedInService", [ getLocalName(name) ]);
        throw new Error(message);
	}
	
	override flash_proxy function callProperty(name:*, ... args:Array):*
	{
		var functionName:String = getLocalName(name);
		var operation:* = ws[functionName];
		
		args.unshift(code.sessionId, code.skey());
		operation.addEventListener(ResultEvent.RESULT, resultHandler)
		return operation.send.apply(null, args);
	}
	
	private function getLocalName(name:Object):String
	{
		if (name is QName)
		{
			return QName(name).localName;
		}
		else
		{
			return String(name);
		}
	}
	
	private function loadHandler(event:LoadEvent):void
	{
		dispatchEvent(new Event('loadWsdlComplete'));
	}
	
	private function faultHandler(event:FaultEvent):void
	{
		var fe:FaultEvent = FaultEvent.createEvent(event.fault, null, event.message);
		dispatchEvent(fe);
	}
	
	private function loginHandler(event:ResultEvent):void
	{
		var resultXML:XML = new XML(<Result />);
		resultXML.appendChild(XMLList(event.result));
		
		code.init(resultXML.Session.HashString);
		code.inputSKey(resultXML.Session.SessionKey);  
		code.sessionId = resultXML.Session.SessionId;
		
		var se:SoapEvent = new SoapEvent(SoapEvent.LOGIN_OK);
		se.result = resultXML;
		dispatchEvent(se);
	}
	
	private function resultHandler(event:ResultEvent):void
	{
		var resultXML:XML = new XML(<Result />);
		resultXML.appendChild(XMLList(event.result));
		
		var se:SoapEvent = new SoapEvent(SoapEvent.RESULT);
		se.result = resultXML;
		 
		event.target.dispatchEvent(se);
	}
	
	// Реализация диспатчера
	
	/**
	 *  @private
	 */
	public function addEventListener(type:String, listener:Function, 
						useCapture:Boolean = false, priority:int = 0, 
						useWeakReference:Boolean = false):void 
	{
			dispatcher.addEventListener(type, listener, useCapture, priority);
	}
	
	/**
	 *  @private
	 */
	public function dispatchEvent(event:Event):Boolean
	{
		return dispatcher.dispatchEvent(event);
	}
	
	/**
	 *  @private
	 */
	public function hasEventListener(type:String):Boolean
	{
		return dispatcher.hasEventListener(type);
	}
	
	/**
	 *  @private
	 */
	public function removeEventListener(type:String, listener:Function, 
									useCapture:Boolean = false):void
	{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
	
	/**
	 *  @private
	 */			
	public function willTrigger(type:String):Boolean
	{
		return dispatcher.willTrigger(type);
	}
}
}