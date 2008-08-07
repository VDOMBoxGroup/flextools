package vdom.events {

import flash.events.Event;
	
public class ExternalManagerEvent extends Event {
	
    // Public constructor.
	public function ExternalManagerEvent(
		type:String, result:Object=null, 
		bubbles:Boolean=false, cancelable:Boolean=false){
			
			// Call the constructor of the superclass.
			super(type, bubbles, cancelable);
			
			// Set the new property.
			this.result = result;
	}

    // Define static constant.
	public static const CALL_COMPLETE:String = 'callComplete';
	public static const CALL_ERROR:String = 'callError';
	
	public static const RESOURCE_LIST_LOADED:String = 'resourceListLoaded';
	
	public static const RESOURCE_LOADING_OK:String = 'resourceLoadingOk';
	public static const RESOURCE_LOADING_ERROR:String = 'resourceLoadingError';
	
	public static const RESOURCE_SAVED:String = 'resourceSaved';
	public static const RESOURCE_SAVED_ERROR:String = 'resourceSavedError';
	
    // Define a public variable to hold the state of the enable property.
	public var result:Object;
	
    // Override the inherited clone() method.
    override public function clone():Event {
        return new ExternalManagerEvent(type, result);
    }
}
}
