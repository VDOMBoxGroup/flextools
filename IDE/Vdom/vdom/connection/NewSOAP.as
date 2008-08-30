package vdom.connection
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.soap.LoadEvent;
import mx.rpc.soap.WebService;

import vdom.connection.protect.MD5;

public dynamic class NewSOAP extends Proxy implements IEventDispatcher
{
	private static var instance:NewSOAP;
	
	private var ws:WebService;
	private var dispatcher:EventDispatcher = new EventDispatcher();

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
		
		ws.open_session.addEventListener(ResultEvent.RESULT, resultHandler);
		ws.open_session(login, password);
	}
	
	override flash_proxy function getProperty(name:*):*
	{
		return "zzz";
	}
	
	override flash_proxy function setProperty(name:*, value:*):void
	{
		var z:* = "";
	}
	
	override flash_proxy function callProperty(name:*, ... args:Array):*
	{
		var name:* = getLocalName(name);
		
		return name;
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
	
	private function resultHandler(event:ResultEvent):void
	{
		var d:* = "";
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