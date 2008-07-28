package vdom.controls.richTextToolBarClasses
{
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import mx.controls.TextInput;

public class sTextInput extends TextInput
{
	public function sTextInput()
	{
		super();
	}
	override protected function createChildren():void
	{
		super.createChildren();
		textField.addEventListener(MouseEvent.MOUSE_UP, zzz, true);
	}
	
	private function zzz(event:MouseEvent):void
	{
		var d:* = "";
		event.stopImmediatePropagation();
	} 
}
}