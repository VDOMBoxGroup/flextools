package vdom.components.editor.events
{

import flash.events.Event;
	
public class WorkspaceEvent extends Event
{
	public static const DELETE_OBJECT:String = "delete object";
	public static const OBJECT_DELETED:String = "object deleted";
	
	public var objectID:String;
	
	public function WorkspaceEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		objectID:String = null):void
	{
		super(type, bubbles, cancelable);
		
		this.objectID = objectID;
	}
	
	override public function clone():Event
	{
		return new ResizeManagerEvent(type, bubbles, cancelable, objectID);
	}		
}
}