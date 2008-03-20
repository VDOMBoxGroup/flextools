package vdom.components.edit.containers.workAreaClasses {

import mx.controls.TextArea;
import flash.events.FocusEvent;
import flash.events.Event;
import mx.events.FlexEvent;

public class WysiwygText extends TextArea {
	
	private var _textFieldHeight:Number;
	
	
	public function WysiwygText() {
		
		super();
		this.addEventListener(FlexEvent.UPDATE_COMPLETE, resizeme);
		//tabEnabled = false;
		//focusEnabled = false;
	}
	
	override protected function focusInHandler(event:FocusEvent):void {
		
	} 
  
   private function resizeme(event:Event):void
   {
       var ta:TextArea = event.target as TextArea;
       ta.explicitHeight = ta.textHeight + 7;
   }  
             
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(textField) {
			this.addEventListener(Event.CHANGE, tf_changeHandler);
		}
	}
	
	private function tf_changeHandler(event:Event):void {
		
		if(_textFieldHeight != textField.textHeight) {
		
			_textFieldHeight = textField.textHeight;
			this.height = _textFieldHeight + 7;
		}
	}
	/* override public function setFocus():void {
		
		
	} */
}
}