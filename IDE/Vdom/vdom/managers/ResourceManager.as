package vdom.managers {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import vdom.connection.soap.Soap;
import vdom.connection.soap.SoapEvent;
	
	
public class ResourceManager implements IEventDispatcher {
	
	private static var instance:ResourceManager;
	
	private var dispatcher:EventDispatcher;
	private var soap:Soap;
	
	private var requestQue:Object;
	private static var _resourceStorage:Object;
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
	
	public function loadResource(ownerID:String, GUID:String, destTarget:Object):void {
		
		trace('load res'+GUID);
		if(_resourceStorage[GUID]) {
			//trace('resource aviable');
			destTarget['resource'] = _resourceStorage[GUID];
			return;
		}
		
		requestQue[GUID] = destTarget;
		soap.addEventListener(SoapEvent.GET_RESOURCE_OK, resourceLoadedHandler);
		soap.getResource(ownerID, GUID);
	}
	
	private function resourceLoadedHandler(event:SoapEvent):void {
		
		var guid:String = event.result.ResourceID;
		var resource:String = event.result.Resource;
		trace(guid);
		_resourceStorage[guid] = resource;
		
		requestQue[guid].resource = resource;
		delete requestQue[guid];
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