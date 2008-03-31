package vdom.events {

import flash.events.Event;
	
public class TransformMarkerEvent extends Event {
	
	public static const TRANSFORM_MARKER_SELECTED:String = "markerSelected";
	public static const TRANSFORM_MARKER_UNSELECTED:String = "markerUnSelected";
	public static const TRANSFORM_CHANGING:String = "changing";
	public static const TRANSFORM_BEGIN:String = "begin";
	public static const TRANSFORM_COMPLETE:String = "complete";
	
	public var properties:Object;
	
	public function TransformMarkerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		properties:Object = null):void {
		
		super(type, bubbles, cancelable);
		
		this.properties = properties;
	}
	
	override public function clone():Event {
		
		return new TransformMarkerEvent(type, bubbles, cancelable, properties);
	}		
}
}