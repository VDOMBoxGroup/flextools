package vdom.events {

import flash.events.Event;
import vdom.components.editor.containers.workAreaClasses.Item;
	
public class ResizeManagerEvent extends Event {
	
	public static const RESIZE_CHANGING:String = "changing";
	public static const RESIZE_BEGIN:String = "begin";
	public static const RESIZE_COMPLETE:String = "complete";
	public static const ITEM_SELECTED:String = "item selected";
	
	public var item:Item;
	public var properties:Object;
	
	public function ResizeManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		item:Item = null,
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