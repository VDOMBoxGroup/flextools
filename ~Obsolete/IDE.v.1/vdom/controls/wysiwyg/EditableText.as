package vdom.controls.wysiwyg
{
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;

import mx.controls.TextArea;
import mx.core.IUITextField;

public class EditableText extends TextArea
{
	private var flexible:Boolean = true;
	
	public function EditableText()
	{
		super();
		editable = false;
	}
	
	override public function set height(value:Number):void
	{
		flexible = false;
		super.height = value;
	}
	
	override protected function childrenCreated():void
    {
        super.childrenCreated();
        callLater(recalculateSize);
        textField.addEventListener(KeyboardEvent.KEY_UP,
        	textField_keyUpHandler);
        textField.addEventListener(Event.RENDER, zzz);
    }
	
	public function get textContainer():IUITextField
	{
		return textField;
	}
	
	override protected function focusInHandler(event:FocusEvent):void
	{
		event.stopImmediatePropagation();
	}
	
	private function textField_keyUpHandler(event:KeyboardEvent):void
	{
		if(!editable)
			return;
			
		recalculateSize();
	}
	
	private function zzz(event:Event):void
	{
		explicitHeight = textField.measuredHeight + 15;
	}
	
	private function recalculateSize():void
	{	
		if(!textField || !flexible)
			return;
		
		explicitHeight = textField.measuredHeight + 15;
		
	}
}
}