package vdom.events
{
import flash.events.Event;

public class TreeEditorEvent extends Event
{
	public static const REDRAW_LINES:String = 'reDraw';
	public static const START_DRAG:String = 'startDrag';
	public static const STOP_DRAG:String = 'stopDrag';	
	public static const DELETE:String = 'delete';
	public static const START_REDRAW_LINES:String = 'startReDrowLines';
	public static const STOP_REDRAW_LINES:String = 'stopReDrowLine';
	public static const START_DRAW_LINE:String = 'startDrowLine';
	public static const RESIZE_TREE_ELEMENT:String = 'resizeTreeElement';
	public static const SHOW_LINES:String = 'showLine';
	public static const HIDE_LINES:String = 'hideLine';
	public static const SELECTED_LEVEL:String = 'selectedLevel';
	public static const CHANGE_START_PAGE:String = 'changeStratPage';
	public static const SAVE_TO_SERVER:String = 'saveToServer';
	public static const NEED_TO_SAVE:String = 'needToSave';
	
	
	
	
	
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