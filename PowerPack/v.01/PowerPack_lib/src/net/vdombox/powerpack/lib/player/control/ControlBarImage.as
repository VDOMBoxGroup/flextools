package net.vdombox.powerpack.lib.player.control
{
	import mx.controls.Image;
	import mx.events.FlexEvent;
	
	public class ControlBarImage extends Image
	{
		
		public var sourceEnabled : Object;
		public var sourceDisabled : Object;
		
		public function ControlBarImage()
		{
			super();
			
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		protected function creationCompleteHandler (event : FlexEvent) : void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			
			source = sourceEnabled;
		}
		
		override public function set enabled (value:Boolean) : void
		{
			super.enabled = value;
			
			source = enabled ? sourceEnabled : sourceDisabled;
		}
		
		
	}
}