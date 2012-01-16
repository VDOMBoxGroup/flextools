package net.vdombox.powerpack.customize.skins
{
	import flash.display.GradientType;
	
	import mx.skins.ProgrammaticSkin;
	
	public class InputAnswerTextBackgroundSkin extends ProgrammaticSkin
	{
		public function InputAnswerTextBackgroundSkin()
		{
			super();
		}
		
		override protected function updateDisplayList( w : Number, h : Number ) : void
		{
			super.updateDisplayList( w, h );
			
			var cornerRadius : Number = getStyle("cornerRadius");
			var gradientColors : Array = getStyle("backgroundGradientColors");
			
			var borderThickness : Number = getStyle("borderThickness");
			var borderColor : int = getStyle("borderColor");
			
			graphics.clear();
			
			drawRoundRect(0, 0, w, h, cornerRadius, borderColor, 1);
			
			var topRectX : Number = borderThickness;
			var topRectY : Number = borderThickness;
			var topRectW : Number = w - 2*borderThickness;
			var topRectH : Number = h - 2*borderThickness;
			
			drawRoundRect(topRectX, topRectY, topRectW, topRectH, cornerRadius, gradientColors, 1, 
				verticalGradientMatrix( topRectX, topRectY, topRectW, topRectH ));
			
		}
		
		
	}
}