package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.ExternalManagerEvent;	

public class ExternalManager implements IExternalManager  {
	
	private var soap:Soap = Soap.getInstance();
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	
	private var _applicationId:String;
	private var _objectId:String;
	
	public function ExternalManager(applicationId:String, objectId:String) {
		
		soap.addEventListener(SoapEvent.REMOTE_METHOD_CALL_OK, callHandler);
		soap.addEventListener(SoapEvent.REMOTE_METHOD_CALL_ERROR, errorHandler);
		_applicationId = applicationId;
		_objectId = objectId;
	}
	
	public function remoteMethodCall(functionName:String, value:String):void {
		
		soap.remoteMethodCall(_applicationId, _objectId, functionName, value); 
	}
	
	private function callHandler(event:SoapEvent):void {
		
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.CALL_COMPLETE);
		eme.result = event.result;
		dispatchEvent(eme);
	}
	
	private function errorHandler(event:SoapEvent):void {
		
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.CALL_ERROR);
		eme.result = event.result;
		dispatchEvent(eme);
	}
	
	
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