package vdom.events
{
import flash.events.Event;

public class AuthenticationEvent extends Event
{
	public static const AUTH_COMPLETE:String = 'authComplete';
	
	public static const AUTH_ERROR:String = 'authError';
	
	public var userName:String;
	
	public function AuthenticationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, userName:String=null)
	{
		super(type, bubbles, cancelable);
		
		this.userName = userName;
	}
	
}
}