package vdom.events
{

import flash.events.Event;
	
public class DataManagerEvent extends Event
{

    // Public constructor.
	public function DataManagerEvent(
		type:String, 
		isEnabled:Boolean=false,
		objectId:String=null){
			
			// Call the constructor of the superclass.
			super(type);
			
			// Set the new property.
			this.isEnabled = isEnabled;
			this.objectId = objectId;
	}

    // Define static constant.
    public static const INIT_COMPLETE:String = 'initComplete';
	public static const TYPES_LOADED:String = 'typesLoaded';
	public static const OBJECTS_LOADED:String = 'objectsLoaded';
	public static const UPDATE_ATTRIBUTES_COMPLETE:String = 'updateAttributesComplete';
	public static const OBJECTS_CREATED:String = 'objectCreated';
	public static const OBJECT_DELETED:String = 'objectDeleted';
	

    // Define a public variable to hold the state of the enable property.
	public var isEnabled:Boolean;
	public var objectId:String;
	
    // Override the inherited clone() method.
    override public function clone():Event {
        return new DataManagerEvent(type, isEnabled);
    }
}
}