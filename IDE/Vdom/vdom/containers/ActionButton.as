package vdom.containers {

import mx.controls.Button;
import mx.controls.ButtonLabelPlacement;

public class ActionButton extends Button {
	
	public function ActionButton() {
		
		super();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, 
	 												unscaledHeight:Number):void {
	 	
	 	super.updateDisplayList(unscaledWidth, unscaledHeight);
	 	
	 	if(labelPlacement == ButtonLabelPlacement.BOTTOM) {
	 		
	 		textField.move((unscaledWidth - textField.width) / 2 + 2, unscaledHeight - textField.height + 3);
	 	}
	 }
	 
	override public function set label(value:String):void {
		
		value = value.toUpperCase();
		super.label = value;
	}
}
}