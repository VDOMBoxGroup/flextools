package vdom.components.edit.containers.typeAccordionClasses {

import flash.geom.Rectangle;

import mx.containers.VBox;
import mx.controls.VScrollBar;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.mx_internal;

import vdom.controls.CustomVScrollBar;

use namespace mx.core.mx_internal;



public class Types extends VBox {
	
	private var mySB:ScrollBar;
	
	public function Types() {
		
		super();
		verticalLineScrollSize = 40;
	}
	
	 override public function validateDisplayList():void {
	 	
	 	super.validateDisplayList();
	 	
	 	if(contentPane && verticalScrollBar) {
	 		
	 		var r:Rectangle = contentPane.scrollRect	 		
	 		contentPane.scrollRect = r;
	 	}
	 }
	
	override public function get verticalScrollBar():ScrollBar {
		
		return mySB;
	}
	
	override public function set verticalScrollBar(value:ScrollBar):void {
		
		if(value) {
			if(value is VScrollBar)
				mySB = new CustomVScrollBar();
				mySB.owner = value.owner;
		} else 
			mySB = value;
	}
}
}