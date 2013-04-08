package vdom.controls {

import mx.controls.VScrollBar;
import mx.core.mx_internal;

use namespace mx.core.mx_internal;

public class CustomVScrollBar extends VScrollBar {
	
	public function CustomVScrollBar() 	{
		
		super();
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if (mx_internal::scrollTrack) {
			
			mx_internal::scrollTrack.visible = false;
		}
		
		if (mx_internal::scrollThumb) {
			
			mx_internal::scrollThumb.visible = false;
		}
		
	}
	
	override public function setScrollProperties(pageSize:Number, 
													minScrollPosition:Number, 
													maxScrollPosition:Number, 
													pageScrollSize:Number=0):void {
		
		super.setScrollProperties(	pageSize, 
									minScrollPosition, 
									maxScrollPosition, 
									pageScrollSize);
		
		if(mx_internal::scrollThumb)
			mx_internal::scrollThumb.visible = false;
	}
}
}