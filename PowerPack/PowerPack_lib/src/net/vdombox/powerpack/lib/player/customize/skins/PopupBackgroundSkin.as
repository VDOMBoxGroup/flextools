package net.vdombox.powerpack.lib.player.customize.skins
{
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;
	
	public class PopupBackgroundSkin extends ProgrammaticSkin
	{
		public function PopupBackgroundSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void 
		{
			var cornerRadius : Number = getStyle("cornerRadius");
			var borderColor : int = getStyle("borderColor");
			var borderWidth : Number = getStyle("borderThickness");
			var backgroundGradientColors : Array = getStyle("backgroundGradientColors");
			
			var bgWidth : Number = w - 2*borderWidth;
			var bgHeight : Number = h - 2*borderWidth;
			
			graphics.clear();
			
			drawRoundRect(0, 0, w, h, cornerRadius, borderColor, 1);
			
			drawRoundRect(borderWidth, borderWidth, bgWidth, bgHeight, cornerRadius, backgroundGradientColors, 1, 
				verticalGradientMatrix(borderWidth, borderWidth, bgWidth, bgHeight));
			
			
			super.updateDisplayList(w, h);
			
		}

	}
}