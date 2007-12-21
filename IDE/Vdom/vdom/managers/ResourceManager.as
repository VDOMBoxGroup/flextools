package vdom.managers {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

import mx.utils.Base64Decoder;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
	
public class ResourceManager implements IEventDispatcher {
	
	private static var instance:ResourceManager;
	
	private var dispatcher:EventDispatcher;
	private var soap:Soap;
	
	private var requestQue:Object;
	private static var _resourceStorage:Object;
	
	private var loader:Loader;
	/**
	 * 
	 * @return instance of ResourceManager class (Singleton)
	 * 
	 */	
	public static function getInstance():ResourceManager
	{
		if (!instance) {
			
			instance = new ResourceManager();
		}

		return instance;
	}
	
	/**
	 * 
	 * Constructor
	 * 
	 */	
	public function ResourceManager() {
		
		if (instance)
			throw new Error("Instance already exists.");
		
		dispatcher = new EventDispatcher();
		soap = Soap.getInstance();
		requestQue = {};
		_resourceStorage = {};
		
	}
	
	public function loadResource(ownerID:String, resourceID:String, destTarget:Object, 
		property:String = 'resource', raw:Boolean = false):void {
		
		if(_resourceStorage[resourceID]) {
			var data:Bitmap = new Bitmap(Bitmap(_resourceStorage[resourceID]).bitmapData);
			if(raw) {
				
				destTarget[property] = data;
				return
			}
			var resourceObject:Object = {resourceID:resourceID, data:data}
			destTarget[property] = resourceObject;
			return;
		}
		
		if(!requestQue[resourceID]) {
			
			requestQue[resourceID] = new Array();
			soap.addEventListener(SoapEvent.GET_RESOURCE_OK, resourceLoadedHandler);
			soap.getResource(ownerID, resourceID);
		}
		
		requestQue[resourceID].push({object:destTarget, property:property, raw:raw});
	}
	
	
	
	private function resourceLoadedHandler(event:SoapEvent):void {
		
		var resourceID:String = event.result.ResourceID;
		var resource:String = event.result.Resource;
		
		var decoder:Base64Decoder = new Base64Decoder();
		decoder.decode(resource);
		
		var imageSource:ByteArray = decoder.drain();
		imageSource.uncompress();
		
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
		loader.name = resourceID;
		loader.loadBytes(imageSource);
		
		_resourceStorage[resourceID] = resource;
	}
	
	private function loadComplete(event:Event):void {
		
		var resourceID:String = event.currentTarget.loader.name;
		_resourceStorage[resourceID] = loader.content;
		
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