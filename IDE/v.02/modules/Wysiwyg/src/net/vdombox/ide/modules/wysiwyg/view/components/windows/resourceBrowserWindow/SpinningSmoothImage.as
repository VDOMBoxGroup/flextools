package net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow
{
	import flash.events.Event;
	
	import mx.effects.Rotate;
	import mx.effects.Tween;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.effects.animation.RepeatBehavior;
	import spark.effects.easing.EasingFraction;
	

	public class SpinningSmoothImage extends SmoothImage
	{
		public static const SPINNING_STARTED : String = "spinningStarted";
		
		private var rotate:Rotate = new Rotate();
		
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
			
			rotate.duration = 5000;
			
			rotate.angleFrom = 0;
			rotate.angleTo = -3600;
			
			rotate.easingFunction = null;
			
			rotate.originX = content.width / 2;
			rotate.originY = content.height / 2;
			
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