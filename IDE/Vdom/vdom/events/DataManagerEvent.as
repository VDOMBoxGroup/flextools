package vdom.events
{

import flash.events.Event;
	
public class DataManagerEvent extends Event
{

    // Public constructor.
	public function DataManagerEvent(
		type:String,
		result:* = null,
		isEnabled:Boolean=false,
		objectId:String=null){
			
			// Call the constructor of the superclass.
			super(type);
			
			// Set the new property.
			this.isEnabled = isEnabled;
			this.objectId = objectId;
			this.result = result;
	}

    // Define static constant.
    public static const INIT_COMPLETE:String = 'initComplete';
    
    public static const APPLICATION_CREATED:String = 'applicationCreated';
    public static const APPLICATION_CHANGED:String = 'applicationChanged';
    
    public static const APPLICATION_DATA_LOADED:String = 'applicationDataLoaded';
    public static const TYPES_LOADED:String = 'typesLoaded';
    public static const PAGE_DATA_LOADED:String = 'pageDataLoaded';
	
	public static const CURRENT_PAGE_CHANGED:String = 'currentPageChanged';
	public static const CURRENT_OBJECT_CHANGED:String = 'currentObjectChanged';
	public static const OBJECT_XML_SCRIPT_LOADED:String = 'objectXMLScriptLoaded';
	
	//public static const OBJECTS_LOADED:String = 'objectsLoaded';
	public static const UPDATE_ATTRIBUTES_COMPLETE:String = 'updateAttributesComplete';
	
	public static const OBJECTS_CREATED:String = 'objectCreated';
	public static const OBJECT_DELETED:String = 'objectDeleted';
	
	public static const STRUCTURE_LOADED:String = 'structureLoaded';
	public static const STRUCTURE_SAVED:String = 'structureSaved';
	

    // Define a public variable to hold the state of the enable property.
	public var isEnabled:Boolean;
	public var objectId:String;
	public var result:XML;
	
    // Override the inherited clone() method.
    override public function clone():Event {
        return new DataManagerEvent(type, isEnabled);
    }
}
}