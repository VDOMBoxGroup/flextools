package net.vdombox.powerpack.lib.player.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	import mx.skins.halo.ScrollTrackSkin;
	
	public class ScrollTrackSkin extends ProgrammaticSkin
	{
		public function ScrollTrackSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number,
											 h:Number):void
		{
			w = 12;
			
			super.updateDisplayList(w, h);
			
			graphics.clear();
			
			drawRoundRect (
				-w, 0, w, h, 1,
				0xffffff, 0);
			
		}
		
		
	}
}