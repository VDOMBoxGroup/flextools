package vdom.components.edit.events
{

import flash.events.Event;
	
public class EditEvent extends Event
{
	public static const DELETE_OBJECT:String = 'deleteObject';
	public static const OBJECT_DELETED:String = 'objectDeleted';
	public static const OBJECT_CHANGE:String = 'objectChange';
	public static const PROPS_CHANGED:String = 'propsChanged';
	
	public var objectId:String;
	public var props:XML;
	
	public function EditEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		objectId:String = null,
		props:XML = null):void
	{
		super(type, bubbles, cancelable);
		
		this.objectId = objectId;
		this.props = props;
	}
	
	override public function clone():Event
	{
		return new EditEvent(type, bubbles, cancelable, objectId, props);
	}		
}
}