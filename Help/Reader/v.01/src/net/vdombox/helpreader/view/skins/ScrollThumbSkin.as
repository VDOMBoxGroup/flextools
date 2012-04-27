package net.vdombox.helpreader.view.skins
{
	import mx.skins.halo.ScrollThumbSkin;
	
	public class ScrollThumbSkin extends mx.skins.halo.ScrollThumbSkin
	{
		public function ScrollThumbSkin()
		{
			super();
		}
		
		override public function get measuredWidth():Number
		{
			return 12;
		}
	}
}