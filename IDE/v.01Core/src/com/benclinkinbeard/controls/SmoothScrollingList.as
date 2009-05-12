package com.benclinkinbeard.controls
{
	import mx.controls.List;
	import mx.core.Container;
	import mx.core.ScrollPolicy;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;

	public class SmoothScrollingList extends List
	{
		public function SmoothScrollingList()
		{
			super();
			
			// required to ensure all renderers get created
			setStyle( "paddingBottom", -1 );
			// parent container will handle scrolling
			verticalScrollPolicy = ScrollPolicy.OFF;
			
			addEventListener( FlexEvent.UPDATE_COMPLETE, handleUpdateComplete );
		}
		
		private function handleUpdateComplete( event:FlexEvent ):void
		{
			var combinedRendererHeight:Number = 0;
			
			// iterate over list of renderers provided by our List subclass
			for each( var renderer:Object in renderers )
			{
				combinedRendererHeight += renderer.height;
			}
			
			// list needs to be at least 10 pixels tall
			// and always needs to be 10 pixels taller than the combined height of the renderers
			height = combinedRendererHeight + 10;
			
			// need to shrink list width when canvas has a scrollbar so the scrollbar doesn't overlap the list
			width = ( Container( parent ).maxVerticalScrollPosition > 0 ) ? parent.width - 16 : parent.width;
		}
		
		// array of renderers being used in this list
		public function get renderers():Array
		{
			// prefix the internal property name with its namespace
			var rawArray:Array = mx_internal::rendererArray;
			var arr:Array = new Array();
			
			// the rendererArray is a bit messy
			// its an Array of Arrays, except sometimes the sub arrays are empty
			// and sometimes it contains entries that aren't Arrays at all
			for each( var obj:Object in rawArray )
			{
				var rendererArray:Array = obj as Array;
				
				// make sure we have an Array and there is something in it
				if( rendererArray && rendererArray.length > 0 )
				{
					// if there is something in it, the first item is our renderer
					arr.push( obj[ 0 ] );
				}
			}
			
			return arr;
		}
	}
}