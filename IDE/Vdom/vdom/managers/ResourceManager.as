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
			
			if(raw) {
				
				destTarget[property] = _resourceStorage[resourceID];
				return
			}
			var resourceObject:Object = {resourceID:resourceID, data:_resourceStorage[resourceID]}
			destTarget[property] = resourceObject;
			return;
		}
		
		requestQue[resourceID] = {object:destTarget, property:property, raw:raw};
		soap.addEventListener(SoapEvent.GET_RESOURCE_OK, resourceLoadedHandler);
		soap.getResource(ownerID, resourceID);
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
		var data:Bitmap = new Bitmap(Bitmap(loader.content).bitmapData);
		
		var requestObject:Object = requestQue[resourceID].object;
		var requestProperty:String = requestQue[resourceID].property;
		
		if(requestQue[resourceID].raw) {
				
			requestObject[requestProperty] = _resourceStorage[resourceID];	
		} else {
			
			requestObject[requestProperty] = {resourceID:resourceID, data:data};
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