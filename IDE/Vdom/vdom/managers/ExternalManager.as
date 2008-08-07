package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.ExternalManagerEvent;
import vdom.events.FileManagerEvent;	

public class ExternalManager implements IExternalManager  {
	
	private var soap:Soap = Soap.getInstance();
	private var fileManager:FileManager = FileManager.getInstance();
	private var dispatcher:EventDispatcher = new EventDispatcher();
	
	private var _applicationId:String;
	private var _objectId:String;
	
	public function ExternalManager(applicationId:String, objectId:String) {
		
		soap.addEventListener(SoapEvent.REMOTE_METHOD_CALL_OK, callHandler);
		soap.addEventListener(SoapEvent.REMOTE_METHOD_CALL_ERROR, errorHandler);
		_applicationId = applicationId;
		_objectId = objectId;
	}
	
	public function remoteMethodCall(functionName:String, value:String):String {
		
		var key:String = soap.remoteMethodCall(_applicationId, _objectId, functionName, value); 
		return key;
	}
	
	public function getListResources():void
	{	
		fileManager.getListResources();
	}
	
	public function loadResource(ownerID:String, resourceID:String, destTarget:Object, 
		property:String = 'resource', raw:Boolean = false):void
	{
		fileManager.loadResource(ownerID, resourceID, destTarget, property, raw);
	}
	
	public function setResource(resType:String, resName:String, resData:ByteArray, applicationId:String = ''):void
	{
		fileManager.setResource(resType, resName, resData, applicationId);
	}
	
	private function registerEvent(flag:Boolean):void
	{
		if(flag)
		{
			fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, listResourcesHandler);
			
			fileManager.addEventListener(FileManagerEvent.RESOURCE_LOADING_OK, resourceLoadedHandler);
			fileManager.addEventListener(FileManagerEvent.RESOURCE_LOADING_ERROR, resourceLoadedErrorHandler);
			
			fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED, setResourceOkHandler);
			fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR , setResourceErrorHandler);
		}
		else
		{
			fileManager.removeEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, listResourcesHandler);
			
			fileManager.removeEventListener(FileManagerEvent.RESOURCE_LOADING_OK, resourceLoadedHandler);
			fileManager.removeEventListener(FileManagerEvent.RESOURCE_LOADING_ERROR, resourceLoadedErrorHandler);
			
			fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED, setResourceOkHandler);
			fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR , setResourceErrorHandler);
		}
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
	
	private function listResourcesHandler(event:SoapEvent):void
	{
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.RESOURCE_LIST_LOADED)
		eme.result = event.result;
		dispatchEvent(eme);
	}
	
	private function resourceLoadedHandler(event:SoapEvent):void
	{
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.RESOURCE_LOADING_OK);
		eme.result = event.result;
		dispatchEvent(eme);
	}
	
	private function resourceLoadedErrorHandler(event:SoapEvent):void
	{	
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.RESOURCE_LOADING_ERROR);
		eme.result = event.result;
		dispatchEvent(eme);
	}
	
	private function setResourceOkHandler(event:SoapEvent):void
	{
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.RESOURCE_SAVED)
		eme.result = event.result;
		dispatchEvent(eme);
	}
	
	private function setResourceErrorHandler(event:SoapEvent):void
	{
		var eme:ExternalManagerEvent = new ExternalManagerEvent(ExternalManagerEvent.RESOURCE_SAVED_ERROR)
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