package vdom.controls
{
import flash.events.FocusEvent;

import mx.controls.TextArea;

public class EditableText extends TextArea
{
	public function EditableText()
	{
		super();
		editable = false;
	}
	
	override protected function focusInHandler(event:FocusEvent):void
	{
		event.stopImmediatePropagation();
	}
}
}