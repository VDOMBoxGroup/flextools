package vdom.components.editor.events
{

import flash.events.Event;
	
public class WorkAreaEvent extends Event
{
	public static const DELETE_OBJECT:String = 'deleteObject';
	public static const OBJECT_DELETED:String = 'objectDeleted';
	public static const OBJECT_CHANGE:String = 'objectChange';
	public static const PROPS_CHANGED:String = 'propsChanged';
	
	public var objectID:String;
	
	public function WorkAreaEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		objectID:String = null):void
	{
		super(type, bubbles, cancelable);
		
		this.objectID = objectID;
	}
	
	override public function clone():Event
	{
		return new WorkAreaEvent(type, bubbles, cancelable, objectID);
	}		
}
}