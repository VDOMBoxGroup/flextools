package vdom.managers {

import mx.containers.Canvas;
import mx.controls.Label;

public class wc extends Canvas {
	
	private var _label:Label;
	/* 
	public function wc() {
		
		super();
		setStyle( "backgroundColor", "#c0c0c0");
	} */
	
	override protected function createChildren():void {
		
		if(!_label)
			_label = new Label();
		
		_label.text = 'test';
		
		addChild(_label);
	}
}
}