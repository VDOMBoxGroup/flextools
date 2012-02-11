package net.vdombox.powerpack.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class BrowseAnswerTextBackgroundSkin extends ProgrammaticSkin
	{
		public function BrowseAnswerTextBackgroundSkin()
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
			
			var gradientRectX : Number = borderThickness;
			var gradientRectY : Number = borderThickness;
			var gradientRectW : Number = w - 2*borderThickness;
			var gradientRectH : Number = h - 2*borderThickness;
			
			graphics.clear();
			
			drawRoundRect(0, 0, w, h, cornerRadius, borderColor, 1);
			drawRoundRect(gradientRectX, gradientRectY, gradientRectW, gradientRectH, cornerRadius, gradientColors, 1, 
				verticalGradientMatrix( gradientRectX, gradientRectY, gradientRectW, gradientRectH ));
			
			
		}
		
		
	}
}