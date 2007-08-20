package vdom.components.editor.events
{

import flash.events.Event;
	
public class DataManagerEvent extends Event
{

    // Public constructor.
    public function DataManagerEvent(type:String, 
        isEnabled:Boolean=false) {
            // Call the constructor of the superclass.
            super(type);

            // Set the new property.
            this.isEnabled = isEnabled;
    }

    // Define static constant.
    public static const TYPES_LOADED:String = "typesLoaded";
    public static const OBJECTS_LOADED:String = "objectsLoaded";

    // Define a public variable to hold the state of the enable property.
    public var isEnabled:Boolean;

    // Override the inherited clone() method.
    override public function clone():Event {
        return new DataManagerEvent(type, isEnabled);
    }
}
}