package vdom.events {

import flash.events.Event;
import flash.utils.ByteArray;
	
public class ImageChooserEvent extends Event {
	
	public static const APPLY:String = 'apply';
	
	public var resource:ByteArray;
	
	public function ImageChooserEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		resource:ByteArray = null):void {
		
		super(type, bubbles, cancelable);
		
		this.resource = resource;
	}
	
	override public function clone():Event {
		
		return new ImageChooserEvent(type, bubbles, cancelable, resource);
	}		
}
}