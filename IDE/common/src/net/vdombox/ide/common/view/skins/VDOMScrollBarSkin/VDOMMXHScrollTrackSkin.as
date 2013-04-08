package net.vdombox.ide.common.view.skins.VDOMScrollBarSkin
{
	import mx.skins.halo.ScrollTrackSkin;

	public class VDOMMXHScrollTrackSkin extends ScrollTrackSkin
	{
		public function VDOMMXHScrollTrackSkin()
		{
			super();
		}

		override public function get measuredWidth() : Number
		{
			return 8;
		}

		override protected function updateDisplayList( w : Number, h : Number ) : void
		{
			super.updateDisplayList( w, h );

			graphics.clear();

			drawRoundRect( 0, 0, w, h, 1, 0x000000, 0.25 );

		}
	}
}
