package vdom.components.editor.events
{

import flash.events.Event;
	
public class ResizeManagerEvent extends Event
{
	public static const RESIZE_CHANGING:String = "changing";
	public static const RESIZE_COMPLETE:String = "complete";
	
	public var properties:Object;
	
	public function ResizeManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
		properties:Object = null):void
	{
		super(type, bubbles, cancelable);
		
		this.properties = properties;
	}
	
	override public function clone():Event
	{
		return new ResizeManagerEvent(type, bubbles, cancelable, properties);
	}		
}
}