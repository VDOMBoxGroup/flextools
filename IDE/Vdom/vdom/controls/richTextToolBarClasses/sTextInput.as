package vdom.controls.richTextToolBarClasses
{
import flash.events.FocusEvent;

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
		textField.addEventListener(FocusEvent.FOCUS_OUT, zzz);
	}
	
	private function zzz(event:FocusEvent):void
	{
		event.stopImmediatePropagation();
	} 
}
}