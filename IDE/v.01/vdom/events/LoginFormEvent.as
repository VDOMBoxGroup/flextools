package vdom.events
{
import flash.events.Event;

public class LoginFormEvent extends Event {
	
	public static const SUBMIT_BEGIN:String = 'submitBegin';
	
	public var formData:Object;
	
	public function LoginFormEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, 
		formData:Object = null) {
			
		super(type, bubbles, cancelable);
		
		this.formData = formData;
	}
}
}