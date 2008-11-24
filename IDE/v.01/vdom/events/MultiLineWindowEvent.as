package vdom.events {
	
import flash.events.Event;

public class MultiLineWindowEvent extends Event {
	
	public var value:String;
	
	public function MultiLineWindowEvent(type:String, value:String) {
		
		this.value = value;
		super(type, false, false);
	}
}
}