package net.vdombox.helpreader.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.HTML;
	import mx.controls.Image;

	public class RightArrow extends Canvas
	{
		[Embed(source='./assets/arrow_left_active.png')]
		[Bindable]
		public var active:Class;
		
		[Embed(source='./assets/arrow_left_inactive.png')]
		[Bindable]
		public var inactive:Class;
		
		[Embed(source='./assets/arrow_left_active_o.png')]
		[Bindable]
		public var active_o:Class;
		
		private var image : Image = new Image();
		
		public function RightArrow()
		{
			super();
			
			addChild(image);
			
			image.source = inactive;
			image.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			image.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		}
		
		private var _htmlPage:HTML;
		public function set htmlPage(HTMLObgect:HTML):void
		{
			_htmlPage = HTMLObgect;
			
			_htmlPage.addEventListener(Event.LOCATION_CHANGE, locationChangeHandler); 
		}
		
		
		private function locationChangeHandler(evt:Event):void
		{
			trace("locationChangeHandler " +  _htmlPage.historyPosition + " of "+ _htmlPage.historyLength);
			if((_htmlPage.historyLength - _htmlPage.historyPosition) > 1)
			{
				image.source = active;
			}
			else
			{
				image.source = inactive;
			}
		}
		
		private function mouseOverHandler(msEvt:MouseEvent):void
		{
			if(image.source == inactive )
				return;
				
			image.source = active_o;
		}
		
		private function mouseOutHandler(msEvt:MouseEvent):void
		{
			if(image.source == inactive )
				return;
				
			image.source = active;
		}
	}
}