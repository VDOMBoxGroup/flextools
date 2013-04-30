package com.zavoo.svg.events {
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	public class SVGMouseEvent extends MouseEvent {
		public static const CLICK:String = 'click';
		public static const MOUSE_DOWN:String = 'mousedown';
		public static const MOUSE_UP:String = 'mouseup';
		public static const MOUSE_OVER:String = 'mouseover';
		public static const MOUSE_MOVE:String = 'mousemove';
		public static const MOUSE_OUT:String = 'mouseout';
		
		private var _target:Object;
		
		public function SVGMouseEvent(target:Object, type:String, bubbles:Boolean=true, cancelable:Boolean=false, 
			localX:Number=0, localY:Number=0, relatedObject:InteractiveObject=null, ctrlKey:Boolean=false, 
			altKey:Boolean=false, shiftKey:Boolean=false, buttonDown:Boolean=false, delta:int=0) {
				
			super(type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			this._target = target;	
			
		}
		
		override public function get target():Object {
			return this._target;
		}
		
	}
}