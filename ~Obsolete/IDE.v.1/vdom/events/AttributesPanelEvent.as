package vdom.events {

import flash.events.Event;
	
public class AttributesPanelEvent extends Event {
	
	public static const DELETE_OBJECT:String = 'deleteObject';
	
	public var objectId:String;
	
	public function AttributesPanelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		objectId:String = null):void {
		
		super(type, bubbles, cancelable);
		
		this.objectId = objectId;
	}
	
	override public function clone():Event {
		
		return new AttributesPanelEvent(type, bubbles, cancelable, objectId);
	}		
}
}