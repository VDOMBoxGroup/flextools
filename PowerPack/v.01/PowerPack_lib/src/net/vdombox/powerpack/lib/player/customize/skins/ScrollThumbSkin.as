package net.vdombox.powerpack.lib.player.customize.skins
{
	import flash.display.GradientType;
	
	import mx.skins.ProgrammaticSkin;
	
	public class ScrollThumbSkin extends ProgrammaticSkin
	{
		public function ScrollThumbSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number,
													  h:Number):void
		{
			super.updateDisplayList(w, h);
			
			graphics.clear();
			
			var cornerRadius	: Number = getStyle("cornerRadius");
			var fillColors		: Array = getStyle("fillColors");
			var gripColor		: int = getStyle("gripColor");	
			
			w = 12;

			drawRoundRect(
				-w, 0, w, h, cornerRadius,
				fillColors, 1,
				horizontalGradientMatrix(-w, 0, w, h),
				GradientType.LINEAR); 
			
			
			// Draw grip.
			var gripW:Number = Math.floor(w / 2);
			var gripX:Number = -w + (w-gripW)/2;
			
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