package vdom.events
{
import flash.events.Event;

public class TreeEditorEvent extends Event
{
	public static const REDRAW:String = 'reDraw';
	public static const START_DRAG:String = 'startDrag';
	public static const STOP_DRAG:String = 'stopDrag';	
	public static const DELETE:String = 'delete';
	public static const START_DRAW_LINE:String = 'startDrowLine';
	public static const RESIZE_TREE_ELEMENT:String = 'resizeTreeElement';
//	public static const DELETE:String = 'delete';
	//canLine.graphics.lineStyle(2, 1, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);	
	//public static const PROXY_ERROR:String = 'proxyError';
	
	public var ID:String;
	
	public function TreeEditorEvent(type:String, ID:String='', bubbles:Boolean=false, cancelable:Boolean=false)
	{
		super(type, bubbles, cancelable);
		
		this.ID = ID;
	}
}
}