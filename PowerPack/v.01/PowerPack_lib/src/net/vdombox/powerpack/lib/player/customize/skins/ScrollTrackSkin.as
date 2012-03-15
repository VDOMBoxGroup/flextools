package net.vdombox.powerpack.lib.player.customize.skins
{
	import mx.skins.halo.ScrollTrackSkin;
	
	public class ScrollTrackSkin extends mx.skins.halo.ScrollTrackSkin
	{
		public function ScrollTrackSkin()
		{
			super();
		}
		
		override public function get measuredWidth():Number
		{
			return 12;
		}
		
		override protected function updateDisplayList (w:Number, h:Number) : void
		{
			super.updateDisplayList(w, h);
			
			graphics.clear();
			
			drawRoundRect ( 0, 0, w, h, 1, 0xffffff, 0);
			
		}
		
		
	}
}