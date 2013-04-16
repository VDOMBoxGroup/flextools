package net.vdombox.powerpack.lib.player.customize.skins
{
	import flash.display.GradientType;
	
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
		
		override protected function updateDisplayList (w:Number, h:Number) : void
		{
			super.updateDisplayList(w, h);
			
			graphics.clear();
			
			var cornerRadius	: Number = getStyle("cornerRadius");
			var fillColors		: Array = getStyle("fillColors");
			var gripColor		: int = getStyle("gripColor");	
			
			drawRoundRect(
				0, 0, w, h, cornerRadius,
				fillColors, 1,
				horizontalGradientMatrix(0, 0, w, h),
				GradientType.LINEAR); 
			
			
			// Draw grip.
			var gripW:Number = Math.floor(w / 2);
			var gripX:Number = 0 + (w-gripW)/2;
			
			drawRoundRect(
				gripX, Math.floor(h / 2 - 4), gripW, 1, 0,
				gripColor, 1);
			
			drawRoundRect(
				gripX, Math.floor(h / 2 - 2), gripW, 1, 0,
				gripColor, 1);
			
			drawRoundRect(
				gripX, Math.floor(h / 2), gripW, 1, 0,
				gripColor, 1);
			
			drawRoundRect(
				gripX, Math.floor(h / 2 + 2), gripW, 1, 0,
				gripColor, 1);
			
			drawRoundRect(
				gripX, Math.floor(h / 2 + 4), gripW, 1, 0,
				gripColor, 1);
		}
	}
}