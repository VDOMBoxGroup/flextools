package net.vdombox.powerpack.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;
	
	public class KeyTextBackgroundSkin extends ProgrammaticSkin
	{
		[Embed(source='/assets/images/key.png')]
		private var backgroundImageClass :Class;
		
		private var backgroundImage :Bitmap;
		private var backgroundBitmapData :BitmapData;
		
		
		public function KeyTextBackgroundSkin()
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
			
			var matrix : Matrix = new Matrix();
			matrix.translate( 10, 11 );
			
			backgroundImage = new backgroundImageClass();
			backgroundBitmapData = new BitmapData( backgroundImage.width, backgroundImage.height, true, 0xffffff);
			backgroundBitmapData.draw( backgroundImage );
			
			graphics.beginBitmapFill(backgroundBitmapData, matrix, false, true); 
			graphics.drawRect(10, 11, backgroundBitmapData.width, backgroundBitmapData.height);
			graphics.endFill();
			
		}
		
		
	}
}