package vdom.events {

import flash.events.Event;

import mx.core.UIComponent;

import vdom.components.edit.containers.workAreaClasses.Item;
	
public class ResizeManagerEvent extends Event {
	
	public static const RESIZE_CHANGING:String = "changing";
	public static const RESIZE_BEGIN:String = "begin";
	public static const RESIZE_COMPLETE:String = "complete";
	public static const ITEM_SELECTED:String = "item selected";
	
	public var item:UIComponent;
	public var properties:Object;
	
	public function ResizeManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		item:UIComponent = null,
		properties:Object = null):void {
		
		super(type, bubbles, cancelable);
		
		this.item = item;
		this.properties = properties;
	}
	
	override public function clone():Event {
		
		return new ResizeManagerEvent(type, bubbles, cancelable, item, properties);
	}		
}
}