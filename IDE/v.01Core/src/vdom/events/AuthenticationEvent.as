package vdom.events {
	
import flash.events.Event;

public class AuthenticationEvent extends Event {
	
//	public static const DATA_CHANGED:String = 'authDataChanged';
	public static const LOGIN_COMPLETE:String = 'loginComplete';
	public static const LOGOUT:String = 'authComplete';
	
	public static const LOGIN_ERROR:String = 'loginError';
	
	public var username:String;
	public var password:String;
	public var hostname:String;
	
	public function AuthenticationEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, 
		username:String = null,
		password:String = null,
		hostname:String = null) {
		super(type, bubbles, cancelable);
		
		this.username = username;
		this.password = password;
		this.hostname = hostname;
	}
}
}