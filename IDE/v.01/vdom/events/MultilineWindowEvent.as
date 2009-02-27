package vdom.events {
	
import flash.events.Event;

public class MultilineWindowEvent extends Event {
	
	public var value:String;
	
	public function MultilineWindowEvent(type:String, value:String) {
		
		this.value = value;
		super(type, false, false);
	}
}
}