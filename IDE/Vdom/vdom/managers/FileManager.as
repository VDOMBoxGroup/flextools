package vdom.managers {

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

import mx.utils.Base64Decoder;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
import vdom.events.FileManagerEvent;
	
public class FileManager implements IEventDispatcher {
	
	private static var instance:FileManager;
	
	private var dispatcher:EventDispatcher;
	private var soap:Soap;
	
	private var requestQue:Object;
	private var _resourceStorage:Object;
	
	private var dataManager:DataManager;
	
	//private var loader:Loader;
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
	public function FileManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		dataManager = DataManager.getInstance();
		requestQue = {};
		_resourceStorage = {};
		
	}
	
	public function getListResources():void {
		
		soap.addEventListener(SoapEvent.LIST_RESOURSES_OK, listResourcesHandler);
		soap.listResources(dataManager.currentApplicationId);
	}
	
	private function listResourcesHandler(event:SoapEvent):void {
		
		soap.removeEventListener(SoapEvent.LIST_RESOURSES_OK, listResourcesHandler);
		
		var fle:FileManagerEvent = new FileManagerEvent(FileManagerEvent.RESOURCE_LIST_LOADED)
		fle.result = event.result;
		dispatchEvent(fle);
	}
	
	public function loadResource(ownerID:String, resourceID:String, destTarget:Object, 
		property:String = 'resource', raw:Boolean = false):void {
		
		if(_resourceStorage[resourceID]) {
			
			if(_resourceStorage[resourceID] is Bitmap) {
			
				var data:Bitmap = new Bitmap(Bitmap(_resourceStorage[resourceID]).bitmapData);
				
				if(raw) {
					
					try {
						destTarget[property] = data;
					} catch (error:Error) {
						var zzz:String = '';
					}
					
					return;
					
				}
			
			
				var resourceObject:Object = {resourceID:resourceID, data:data}
				destTarget[property] = resourceObject;
				return;
			}
		}
		
		if(!requestQue[resourceID]) {
			
			requestQue[resourceID] = new Array();
			soap.addEventListener(SoapEvent.GET_RESOURCE_OK, resourceLoadedHandler);
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
	
	private function resourceLoadedHandler(event:SoapEvent):void {
		
		var resourceID:String = event.result.ResourceID;
		var resource:String = event.result.Resource;
		
		var decoder:Base64Decoder = new Base64Decoder();
		decoder.decode(resource);
		
		var imageSource:ByteArray = decoder.drain();
		
		imageSource.uncompress();
		
		_resourceStorage[resourceID] = imageSource;
		
		for each(var item:Object in requestQue[resourceID]) {
			
			var data:ByteArray = new ByteArray();
			_resourceStorage[resourceID].readBytes(data);
			//ByteArray(_resourceStorage[resourceID]).writeBytes(data);
			var requestObject:Object = item.object;
			var requestProperty:String = item.property;
			
			if(item.raw) {
					
				requestObject[requestProperty] = data;	
			} else {
				
				requestObject[requestProperty] = {resourceID:resourceID, data:data};
			}
		}
		
		delete requestQue[resourceID];
	}
	
	/* private function loadComplete(event:Event):void {
		
		var resourceID:String = event.currentTarget.loader.name;
		
		_resourceStorage[resourceID] = event.currentTarget.loader.content;
		
		for each(var item:Object in requestQue[resourceID]) {
			
			var data:Bitmap = new Bitmap(Bitmap(_resourceStorage[resourceID]).bitmapData);
			var requestObject:Object = item.object;
			var requestProperty:String = item.property;
			
			if(item.raw) {
					
				requestObject[requestProperty] = data;	
			} else {
				
				requestObject[requestProperty] = {resourceID:resourceID, data:data};
			}
		}
		
		delete requestQue[resourceID];
	} */
	
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