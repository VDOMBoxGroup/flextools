package vdom.events {

import flash.events.Event;

import mx.core.UIComponent;
	
public class TransformMarkerEvent extends Event {
	
	public static const TRANSFORM_MARKER_SELECTED:String = "markerSelected";
	public static const TRANSFORM_MARKER_UNSELECTED:String = "markerUnSelected";
	public static const TRANSFORM_CHANGING:String = "changing";
	public static const TRANSFORM_BEGIN:String = "begin";
	public static const TRANSFORM_COMPLETE:String = "complete";
	
	public var properties:Object;
	public var item:UIComponent;
	
	public function TransformMarkerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		item:UIComponent = null,
		properties:Object = null):void {
		
		super(type, bubbles, cancelable);
		
		this.properties = properties;
		this.item = item;
	}
	
	override public function clone():Event {
		
		return new TransformMarkerEvent(type, bubbles, cancelable, item, properties);
	}		
}
}