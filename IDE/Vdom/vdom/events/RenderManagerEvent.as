package vdom.events {

import flash.events.Event;

import mx.core.UIComponent;
import vdom.components.editor.containers.workAreaClasses.Item;
	
public class RenderManagerEvent extends Event {
	
    // Public constructor.
	public function RenderManagerEvent(
		type:String, result:Item=null, 
		bubbles:Boolean=false, cancelable:Boolean=false){
			
			// Call the constructor of the superclass.
			super(type, bubbles, cancelable);
			
			// Set the new property.
			this.result = result;
	}

    // Define static constant.
	public static const RENDER_COMPLETE:String = 'renderComlete';
	public static const RENDER_ROLL_OVER:String = 'renderItemRollOver';
	public static const RENDER_ROLL_OUT:String = 'renderItemRollOut';

    // Define a public variable to hold the state of the enable property.
	public var result:Item;
	
    // Override the inherited clone() method.
    override public function clone():Event {
        return new RenderManagerEvent(type, result);
    }
}
}