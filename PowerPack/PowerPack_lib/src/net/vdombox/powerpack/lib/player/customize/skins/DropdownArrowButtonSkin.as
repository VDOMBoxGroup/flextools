package net.vdombox.powerpack.lib.player.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;
	
	public class DropdownArrowButtonSkin extends ProgrammaticSkin
	{
		[Embed(source='/assets/images/dropdownArrow.png')]
		private var triangleImageClass	: Class;
		
		private var triangleImage		: Bitmap;
		private var triangleBitmapData	: BitmapData;
		
		public function DropdownArrowButtonSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void 
		{
			super.updateDisplayList(w, h);
			
			var cornerRadius					: Number = getStyle("cornerRadius");
			var backgroundGradientColors		: Array = getStyle("backgroundGradientColors");
			var backgroundOverGradientColors	: Array	= getStyle("backgroundOverGradientColors");
			var borderColor						: int = getStyle("borderColor");
			var shadowColor						: int = getStyle("shadowColor");
			var triangleLineColors				: Array = getStyle("triangleLineColors");
			
			var triabgleDistX : Number = 6;
			var triangleX : Number = w-13-triabgleDistX;
			var triangleY : Number = h/2-4;
			
			var triangleBgX : Number = triangleX-triabgleDistX;
			var triangleBgW : Number = w - triangleBgX;
			
			graphics.clear();
			
			if (name == "downSkin" || name == "overSkin")
			{
				drawRoundRect(0, 0, w, h, cornerRadius, backgroundOverGradientColors, 1, verticalGradientMatrix(0, 0, w, h));
				drawRoundRect(triangleBgX, 0, triangleBgW, h, {tl: 0, tr: cornerRadius, bl: 0, br: cornerRadius}, [0xbdbdbd, 0x696969], 1, 
					verticalGradientMatrix(triangleBgX, 0, triangleBgW, h));	
			}
			else
			{
				drawRoundRect(0, 0, w, h, cornerRadius, backgroundGradientColors, 1, verticalGradientMatrix(0, 0, w, h));
			}
			
			// Draw the triangle ...
			var matrix : Matrix = new Matrix();
			matrix.translate( triangleX, triangleY );
			
			triangleImage = new triangleImageClass();
			triangleBitmapData = new BitmapData( triangleImage.width, triangleImage.height, true, 0xffffff);
			triangleBitmapData.draw( triangleImage );
			
			graphics.beginBitmapFill(triangleBitmapData, matrix, false, true); 
			graphics.drawRect(triangleX, triangleY, triangleBitmapData.width, triangleBitmapData.height);
			graphics.endFill();
			
			graphics.moveTo(triangleX, triangleY+1);
			graphics.lineStyle(1, triangleLineColors[0], 1);
			graphics.lineTo(triangleX+triangleBitmapData.width/2, triangleY+triangleBitmapData.height);
			graphics.lineStyle(1, triangleLineColors[1], 1);
			graphics.lineTo(triangleX+triangleBitmapData.width, triangleY+1);
			// ... Draw the triangle
			
			filters = [new GlowFilter(borderColor, 1, 1, 1), new DropShadowFilter(1, 45, shadowColor, 0.5, 3, 3, 0.5)];
		}
		
		
	}
}