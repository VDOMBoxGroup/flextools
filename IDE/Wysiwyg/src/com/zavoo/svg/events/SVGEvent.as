package com.zavoo.svg.events {
	import flash.events.Event;

	public class SVGEvent extends Event {
		
		public static const SVG_LOAD:String = 'SVGLoad';
		public static const SVG_UNLOAD:String = 'SVGUnload';
		//public static const SVG_ABORT:String = 'SVGAbort';
		//public static const SVG_ERROR:String = 'SVGError';
		//public static const SVG_SCROLL:String = 'SVGScroll';
		//public static const SVG_ZOOM:String = 'SVGZoom';
		
		//public static const BEGIN_EVENT:String = 'beginEvent';
		//public static const END_EVENT:String = 'endEvent';
		//public static const REPEAT_EVENT:String = 'repeatEvent';
		
		
		
		//public static const RENDER_FINISHED:String = 'SVG Render Finished';
		
		public function SVGEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}
}