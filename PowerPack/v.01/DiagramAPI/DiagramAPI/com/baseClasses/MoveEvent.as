package DiagramAPI.com.baseClasses
{
import flash.display.InteractiveObject;
import flash.events.MouseEvent;

public class MoveEvent extends MouseEvent
{
   	public static const MOVE_STARTING:String = "moveStarting";
   	public static const MOVE_START:String = "moveStart";
   	public static const MOVE_END:String = "moveEnd";
   	public static const MOVED:String = "moved";
   		
	public function MoveEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false, localX:Number=0, localY:Number=0, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0)
	{
		super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
	}	
}
}