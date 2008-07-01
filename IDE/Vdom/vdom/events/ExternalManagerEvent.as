package vdom.events {

import flash.events.Event;
	
public class ExternalManagerEvent extends Event {
	
    // Public constructor.
	public function ExternalManagerEvent(
		type:String, result:String=null, 
		bubbles:Boolean=false, cancelable:Boolean=false){
			
			// Call the constructor of the superclass.
			super(type, bubbles, cancelable);
			
			// Set the new property.
			this.result = result;
	}

    // Define static constant.
	public static const CALL_COMPLETE:String = 'callComplete';
	public static const CALL_ERROR:String = 'callError';

    // Define a public variable to hold the state of the enable property.
	public var result:String;
	
    // Override the inherited clone() method.
    override public function clone():Event {
        return new ExternalManagerEvent(type, result);
    }
}
}
