package vdom.events
{
import flash.events.Event;

public class EditAreaEvent extends Event
{
	public static var SAVE :String = "save";
	
	public var content : String;
	
	public function EditAreaEvent(type:String, 
								bubbles:Boolean = false,
							 	cancelable:Boolean = true,
							 	content : String = null)
	{
		super(type, bubbles, cancelable);

		this.content = content;
	}
	
	override public function clone():Event
	{
		return new EditAreaEvent(type, bubbles, cancelable, content);
	}
}
}