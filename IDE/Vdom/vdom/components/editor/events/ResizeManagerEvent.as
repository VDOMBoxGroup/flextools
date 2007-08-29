package vdom.components.editor.events
{

import flash.events.Event;
	
public class ResizeManagerEvent extends Event
{
	public static const RESIZE_CHANGING:String = "changing";
	public static const RESIZE_COMPLETE:String = "complete";
	
	public function ResizeManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event
	{
		return new ResizeManagerEvent(type, bubbles, cancelable);
	}		
}
}