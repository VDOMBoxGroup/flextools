package net.vdombox.helpreader.view 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.HTML;
	import mx.controls.Image;

	public class LeftArrow extends Canvas
	{
		[Embed(source='./assets/arrow_right_active.png')]
		[Bindable]
		public var active:Class;
		
		[Embed(source='./assets/arrow_right_inactive.png')]
		[Bindable]
		public var inactive:Class;
		
		[Embed(source='./assets/arrow_right_active_o.png')]
		[Bindable]
		public var active_o:Class;
		
		private var image : Image = new Image();
		
		public function LeftArrow()
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
			if(_htmlPage.historyPosition)
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