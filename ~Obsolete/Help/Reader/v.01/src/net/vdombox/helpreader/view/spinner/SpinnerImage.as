package net.vdombox.helpreader.view.spinner
{
	import flash.events.Event;
	
	import mx.controls.Image;
	import mx.effects.Rotate;
	import mx.effects.easing.Linear;
	
	public class SpinnerImage extends Image
	{
		public static const SPINNING_STARTED : String = "spinningStarted";
		
		private var rotate		: Rotate = new Rotate();
		
		public var duration	: Number = 600;
		public var angle	: Number = -360;
		
		public function SpinnerImage()
		{
			super();
		}
		
		public function rotateImage():void
		{
			if (!content) 
				return;
			
			rotate.target = content;
			
			rotate.duration = duration;
			
			rotate.angleFrom = 0;
			rotate.angleTo = angle;
			
			rotate.easingFunction = Linear.easeNone;
			
			if ((content.width < width) || (content.height < height))
			{
				rotate.originX = content.width / 2;
				rotate.originY = content.height / 2;
			} else {
				rotate.originX = width / 2;
				rotate.originY = height / 2;
			}
			
			rotate.repeatCount = 0;
			rotate.repeatDelay = 0;
			
			rotate.play();
			
			this.dispatchEvent(new Event(SPINNING_STARTED));
			
		}
		
		
		public function stopRotateImage():void
		{
			rotate.stop();
		}
		
	}
}