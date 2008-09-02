package vdom.events {

import flash.events.Event;
	
public class WorkAreaEvent extends Event {
	
	public static const CREATE_OBJECT:String = 'createObject';
	public static const CHANGE_OBJECT:String = 'changeObject';
	public static const PROPS_CHANGED:String = 'propsChanged';
	
	public var typeId:String;
	public var objectId:String;
	public var props:XML;
	
	public function WorkAreaEvent(type:String, bubbles:Boolean = false,
								cancelable:Boolean = false,	typeId:String = null, 
								objectId:String = null, props:XML = null):void
	{
		super(type, bubbles, cancelable);
		
		this.typeId = typeId;
		this.objectId = objectId;
		this.props = props;
	}
	
	override public function clone():Event
	{
		return new WorkAreaEvent(type, bubbles, cancelable, typeId, objectId, props);
	}
}
}