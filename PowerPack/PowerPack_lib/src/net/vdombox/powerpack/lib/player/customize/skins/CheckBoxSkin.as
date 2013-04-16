package net.vdombox.powerpack.lib.player.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import mx.skins.Border;
	import mx.skins.ProgrammaticSkin;
	import mx.skins.halo.CheckBoxIcon;
	
	public class CheckBoxSkin extends Border
	{
		[Embed(source='/assets/images/checkMark.png')]
		private var CheckMarkImageClass	: Class;
		
		private var checkMarkImage		: Bitmap;
		private var checkMarkBitmapData	: BitmapData;
		
		
		public function CheckBoxSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			var borderGradientColors:Array = getStyle("borderGradientColors");
			var borderThickness:uint = getStyle("borderThickness");
			var fillGradientColors:Array = getStyle("fillGradientColors");
			
			var r:Number = getStyle("iconRadius");
			graphics.clear();
			
			var graphicsWidth : Number = getStyle("paddingLeft") - 4;
			var graphicsY : Number = (h-graphicsWidth) / 2;
			
			// RadioButton border
			graphics.beginGradientFill(GradientType.LINEAR, borderGradientColors, [1,1], [0,0xFF], 
											verticalGradientMatrix(0,graphicsY,graphicsWidth,graphicsWidth));
			graphics.drawRect(0,graphicsY,graphicsWidth,graphicsWidth);
			graphics.endFill();
			
			// RadioButton fill
			graphics.beginGradientFill(GradientType.LINEAR, fillGradientColors, [1, 1], [0,0xFF], 
											verticalGradientMatrix(0, graphicsY, graphicsWidth-2*borderThickness, graphicsWidth-2*borderThickness-1));
			graphics.drawRect(borderThickness, graphicsY+borderThickness+1, graphicsWidth-2*borderThickness, graphicsWidth-2*borderThickness-1);
			graphics.endFill();
			
			if (name == "selectedUpSkin" || 
				name == "selectedOverSkin" || 
				name == "selectedDownSkin" ||
				name == "selectedDisabledSkin")
			{
				checkMarkImage = new CheckMarkImageClass();
				checkMarkBitmapData = new BitmapData( checkMarkImage.width, checkMarkImage.height, true, 0xffffff);
				checkMarkBitmapData.draw( checkMarkImage );
				
				var markX : Number = (graphicsWidth - checkMarkImage.width) / 2;
				var markY : Number = (graphicsWidth - checkMarkImage.height) / 2 + graphicsY + 1;
				
				var matrix : Matrix = new Matrix();
				matrix.translate( markX, markY );
				
				
				
				graphics.beginBitmapFill(checkMarkBitmapData, matrix, false, true); 
				graphics.drawRect(markX, markY, checkMarkBitmapData.width, checkMarkBitmapData.height);
				graphics.endFill();
			}
		}
	}
}