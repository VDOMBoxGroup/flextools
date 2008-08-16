package vdom.managers
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

import mx.utils.Base64Decoder;
import mx.utils.Base64Encoder;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.FileManagerEvent;
	
public class FileManager implements IEventDispatcher
{
	private static var instance:FileManager;
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	private var soap:Soap = Soap.getInstance();
	
	private var requestQue:Object = {};
	private var _resourceStorage:Object = {};
	
	private var dataManager:DataManager = DataManager.getInstance();
	private var cacheManager:CacheManager = CacheManager.getInstance();
	
	private var applicationId:String;
	
	/**
	 * 
	 * @return instance of ResourceManager class (Singleton)
	 * 
	 */	
	public static function getInstance():FileManager
	{
		if (!instance) {
			
			instance = new FileManager();
		}
		
		return instance;
	}
	
	/**
	 * 
	 * Constructor
	 * 
	 */	
	public function FileManager()
	{
		if (instance)
			throw new Error("Instance already exists.");
		
		registerEvent(true);
	}
	
	public function getListResources(ownerId:String = ""):void
	{	
		if(ownerId == "")
			ownerId = dataManager.currentApplicationId;
		
		soap.listResources(ownerId);
	}
	
	private function registerEvent(flag:Boolean):void
	{
		if(flag)
		{
			soap.addEventListener(SoapEvent.LIST_RESOURSES_OK, listResourcesHandler);
			
			soap.addEventListener(SoapEvent.GET_RESOURCE_OK, resourceLoadedHandler);
			soap.addEventListener(SoapEvent.GET_RESOURCE_ERROR, resourceLoadedErrorHandler);
			
			soap.addEventListener(SoapEvent.SET_RESOURCE_OK , setResourceOkHandler);
			soap.addEventListener(SoapEvent.SET_RESOURCE_ERROR , setResourceErrorHandler);
		}
		else
		{
			soap.removeEventListener(SoapEvent.LIST_RESOURSES_OK, listResourcesHandler);
			
			soap.removeEventListener(SoapEvent.GET_RESOURCE_OK, resourceLoadedHandler);
			soap.removeEventListener(SoapEvent.GET_RESOURCE_ERROR, resourceLoadedErrorHandler);
			
			soap.removeEventListener(SoapEvent.SET_RESOURCE_OK , setResourceOkHandler);
			soap.removeEventListener(SoapEvent.SET_RESOURCE_ERROR , setResourceErrorHandler);
		}
	}
	
	private function listResourcesHandler(event:SoapEvent):void
	{
		var fle:FileManagerEvent = new FileManagerEvent(FileManagerEvent.RESOURCE_LIST_LOADED)
		fle.result = event.result;
		dispatchEvent(fle);
	}
	
	public function loadResource(ownerID:String, resourceID:String, destTarget:Object, 
		property:String = 'resource', raw:Boolean = false):void
	{		
		if(!resourceID)
			return;
		
		var result:ByteArray = cacheManager.getCachedFileById(resourceID);
		
		if(result)
		{	
			if(raw)
				destTarget[property] = result;
			else
				destTarget[property] = {resourceID:resourceID, data:result}
			return;
		}
		
		if(!requestQue[resourceID])
		{	
			requestQue[resourceID] = new Array();
			soap.getResource(ownerID, resourceID);
		}
		
		requestQue[resourceID].push(
			{
				object:destTarget, 
				property:property, 
				raw:raw
			}
		);
	}
	
	private function resourceLoadedHandler(event:SoapEvent):void
	{	
		var resourceID:String = event.result.ResourceID;
		var resource:String = event.result.Resource;
		
		var decoder:Base64Decoder = new Base64Decoder();
		decoder.decode(resource);
		
		var imageSource:ByteArray = decoder.toByteArray();
		
		imageSource.uncompress();
		
		cacheManager.cacheFile(resourceID, imageSource);

		imageSource.position = 0;
		_resourceStorage[resourceID] = imageSource;
		
		for each(var item:Object in requestQue[resourceID])
		{	
			var data:ByteArray = new ByteArray();
			_resourceStorage[resourceID].readBytes(data);
			_resourceStorage[resourceID].position = 0;
			
			var requestObject:Object = item.object;
			var requestProperty:String = item.property;
			
			if(item.raw)		
				requestObject[requestProperty] = data;	
			else
				requestObject[requestProperty] = {resourceID:resourceID, data:data};
		}
		
		delete requestQue[resourceID];
		
		var fme:FileManagerEvent = new FileManagerEvent(FileManagerEvent.RESOURCE_LOADING_OK);
		fme.result = event.result;
		dispatchEvent(fme);
	}
	
	private function resourceLoadedErrorHandler(event:SoapEvent):void
	{
		var resourceId:String = event.result.ResourceID[0];
		
		if(requestQue[resourceId])
			delete requestQue[resourceId];
		
		var fme:FileManagerEvent = new FileManagerEvent(FileManagerEvent.RESOURCE_LOADING_ERROR);
		fme.result = event.result;
		dispatchEvent(fme);
	}
	
	public function setResource(resType:String, resName:String, resData:ByteArray, applicationId:String = ''):void
	{
		resData.compress();
		
		var base64Data:Base64Encoder = new Base64Encoder();
		base64Data.insertNewLines = false;
		base64Data.encodeBytes(resData);
		
		if(!applicationId)
			applicationId = dataManager.currentApplicationId;
		
		soap.setResource(applicationId, resType, resName, base64Data.toString());
	}
	
	private function setResourceOkHandler(event:SoapEvent):void
	{
		var fme:FileManagerEvent = new FileManagerEvent(FileManagerEvent.RESOURCE_SAVED)
		fme.result = event.result;
		dispatchEvent(fme);
	}
	
	private function setResourceErrorHandler(event:SoapEvent):void
	{
		var fme:FileManagerEvent = new FileManagerEvent(FileManagerEvent.RESOURCE_SAVED_ERROR)
		fme.result = event.result;
		dispatchEvent(fme);
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
    public function dispatchEvent(evt:Event):Boolean
    {
        return dispatcher.dispatchEvent(evt);
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
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
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