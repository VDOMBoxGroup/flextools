package vdom.events {
	
import flash.events.Event;

public class ColorPickerEvent extends Event {
	
	public var color:uint;
	public var hexcolor:String;
	
	public function ColorPickerEvent(type:String, color:uint, hexcolor:String) {
		
		this.color = color;
		this.hexcolor = hexcolor;
		super(type, false, false);
	}
}
}