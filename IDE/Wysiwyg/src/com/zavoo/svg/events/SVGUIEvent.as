package com.zavoo.svg.events {
	import flash.events.Event;

	public class SVGUIEvent extends Event {
		public static const FOCUS_IN:String = 'focusin';
		public static const FOCUS_OUT:String = 'focusout';
		public static const ACTIVATE:String = 'activate';
		
		private var _target:Object;
		
		public function SVGUIEvent(target:Object, type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this._target = target;			
		}
		
		override public function get target():Object {
			return this._target;
		}
		
	}
}