package net.vdombox.powerpack.customize.skins
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.skins.ProgrammaticSkin;
	
	public class GradientButtonSkin extends ProgrammaticSkin
	{
		public function GradientButtonSkin()
		{
			super();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			graphics.clear();
			
			var bgColors : Array = getStyle( "buttonBgColors" );
			
			var matr:Matrix = new Matrix();
			matr.createGradientBox(unscaledWidth, unscaledHeight, 1.57, 0, 0);
			
			graphics.beginGradientFill(GradientType.LINEAR, 
										[bgColors[0], bgColors[1]], 
										[1,1], [0x44,0xff], 
										matr)
			
			graphics.drawRoundRect(0, 0, 
									unscaledWidth, unscaledHeight,
									unscaledWidth-55,unscaledHeight);
			graphics.endFill();
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
	}
}