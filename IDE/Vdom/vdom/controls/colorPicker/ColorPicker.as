package vdom.controls.colorPicker {

import flash.events.MouseEvent;

import mx.containers.Box;

import vdom.events.ColorPickerEvent;

public class ColorPicker extends Box {
	
	private var _color:String;
	
	public function ColorPicker() {
		
		super();
		
		//addEventListener("change", colorChangeHandler);
		
		buttonMode = true;
		
		addEventListener(MouseEvent.CLICK, mouseClickandler);
		
		addEventListener("apply",  colorCompleteHandler);
		addEventListener("cancel", colorCompleteHandler);	
	}
	
	public function get color():String {
		
		return _color;
	}
	
	public function set color(colorValue:String):void {
		
		setStyle(
			'backgroundColor', 
			Number('0x' + colorValue.toString().substring(1))
		);
		
		_color = colorValue;
	}
	
	private function mouseClickandler(event:MouseEvent) :void {
		
		var colorInt:uint = Number('0x' + _color.substring(1));
		ColorPickerWindow.show_window(this, colorInt, true);
	}
	
	private function colorCompleteHandler(event:ColorPickerEvent):void {
		
		if(event.type == 'apply') {
			
			color = '#' + event.hexcolor;
		}
		
	}
}
}