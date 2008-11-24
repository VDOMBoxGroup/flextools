package vdom.events
{
import flash.events.Event;

import mx.rpc.Fault;
	
public class DataManagerErrorEvent extends Event
{
	// Define static constant.
	public static const GLOBAL_ERROR:String = 'globalError';
	public static const OBJECT_XML_SCRIPT_SAVE_ERROR:String = 'objectXMLScriptSaveError';
	public static const SET_NAME_ERROR:String = 'setNameError';
	
	// Define a public variable to hold the state of the enable property.
	public var isEnabled:Boolean;
	public var objectId:String;
	public var fault:Fault;
	public var key:String;
	
	// Public constructor.
	public function DataManagerErrorEvent(type:String, fault:Fault = null,
								isEnabled:Boolean = false, objectId:String = null,
								key:String = '')
	{		
		// Call the constructor of the superclass.
		super(type);
		
		// Set the new property.
		this.isEnabled = isEnabled;
		this.objectId = objectId;
		this.fault = fault;
		this.key = key;
	}

	// Override the inherited clone() method.
	override public function clone():Event {
		return new DataManagerEvent(type, isEnabled);
	}
}
}