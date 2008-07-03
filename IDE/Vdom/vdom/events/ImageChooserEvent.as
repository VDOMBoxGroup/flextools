package vdom.events {

import flash.display.Bitmap;
import flash.events.Event;
	
public class ImageChooserEvent extends Event {
	
	public static const APPLY:String = 'apply';
	
	public var name:String;
	public var resource:Bitmap;
	
	public function ImageChooserEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		name:String = null,
		resource:Bitmap = null):void {
		
		super(type, bubbles, cancelable);
		
		this.name = name;
		this.resource = resource;
	}
	
	override public function clone():Event {
		
		return new ImageChooserEvent(type, bubbles, cancelable, name, resource);
	}		
}
}