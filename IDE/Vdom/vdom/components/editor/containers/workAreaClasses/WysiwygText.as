package vdom.components.editor.containers.workAreaClasses {

import mx.controls.TextArea;
import flash.events.FocusEvent;

public class WysiwygText extends TextArea {
	
	public function WysiwygText() {
		
		super();
		tabEnabled = false;
		focusEnabled = false;
	}
	
	override protected function focusInHandler(event:FocusEvent):void {
		
	} 
	
	/* override public function setFocus():void {
		
		
	} */
}
}