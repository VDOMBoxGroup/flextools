package net.vdombox.powerpack.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.filters.DropShadowFilter;
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
			
			var keyImageX : Number = 10;
			var keyImageY : Number = 11;
			
			var matrix : Matrix = new Matrix();
			matrix.translate( keyImageX, keyImageY );
			
			backgroundImage = new backgroundImageClass();
			backgroundBitmapData = new BitmapData( backgroundImage.width, backgroundImage.height, true, 0xffffff);
			backgroundBitmapData.draw( backgroundImage );
			
			graphics.beginBitmapFill(backgroundBitmapData, matrix, false, true); 
			graphics.drawRect(keyImageX, keyImageY, backgroundBitmapData.width, backgroundBitmapData.height);
			graphics.endFill();
			
			filters = [new DropShadowFilter(7, 45, 0x000000, 0.2,4,4,1,1,true)];
			
		}
		
		
	}
}