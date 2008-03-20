package vdom.components.edit.containers.workAreaClasses {

import flash.events.MouseEvent;

import mx.controls.RadioButton;
import flash.events.FocusEvent;
import mx.managers.IFocusManager;

public class WysiwygRadioButton extends RadioButton {
	
	override protected function clickHandler(event:MouseEvent):void {
		
		if (!enabled || selected)
			return; // prevent a selected button from dispatching "click"
	}
	
}
}