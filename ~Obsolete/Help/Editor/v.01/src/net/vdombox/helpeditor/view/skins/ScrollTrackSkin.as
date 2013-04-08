package net.vdombox.helpeditor.view.skins
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
	}
}