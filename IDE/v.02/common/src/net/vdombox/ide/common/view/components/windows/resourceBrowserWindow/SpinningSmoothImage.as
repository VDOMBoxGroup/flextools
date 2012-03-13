package net.vdombox.ide.common.view.components.windows.resourceBrowserWindow
{
	import flash.events.Event;
	
	import mx.effects.Rotate;
	import mx.effects.Tween;
	import mx.effects.easing.Linear;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.effects.animation.RepeatBehavior;
	import spark.effects.easing.EaseInOutBase;
	import spark.effects.easing.EasingFraction;
	

	public class SpinningSmoothImage extends SmoothImage
	{
		public static const SPINNING_STARTED : String = "spinningStarted";
		
		private var rotate		: Rotate = new Rotate();
		
		public var duration	: Number = 500;
		public var angle	: Number = -360;
		
		public function SpinningSmoothImage()
		{
			super();
			
			autoLoad = true;
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete, false, 0, true);
						
		}
		
		private function onCreationComplete (evt:Event) : void 
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
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