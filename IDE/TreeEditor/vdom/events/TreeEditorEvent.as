package vdom.events
{
import flash.events.Event;

public class TreeEditorEvent extends Event
{
	public static const REDRAW:String = 'reDraw';
	public static const START_DRAG:String = 'startDrag';
	public static const STOP_DRAG:String = 'stopDrag';	
	//public static const PROXY_ERROR:String = 'proxyError';
	
	public var ID:String;
	
	public function TreeEditorEvent(type:String, ID:String='', bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		
		this.ID = ID;
	}
}
}