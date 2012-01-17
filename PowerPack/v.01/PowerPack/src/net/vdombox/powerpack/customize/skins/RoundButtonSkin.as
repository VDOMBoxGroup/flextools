package net.vdombox.powerpack.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.skins.ProgrammaticSkin;
	import mx.states.SetStyle;
	
	import net.vdombox.powerpack.control.RoundButton;
	
	public class RoundButtonSkin extends ProgrammaticSkin
	{
		public function RoundButtonSkin()
		{
			super();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var cornerRadius : Number = getStyle("cornerRadius");
			var fillColors : Array = getStyle("fillColors");
			var fillColorDisabled : int = getStyle("fillColorDisabled");
			var disabledfillColorBevelFilter : int = getStyle("disabledfillColorBevelFilter");
			
			graphics.clear();
			
			if (RoundButton(parent).enabled)
			{
				drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, fillColors, 1, 
							verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));
			} else
			{
				drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, fillColorDisabled, 1);
				filters = [new BevelFilter(0.7, 85, disabledfillColorBevelFilter, 1, disabledfillColorBevelFilter, 0.2)];
			}
				
			
			
			if (name == "downSkin" || name == "overSkin")
			{
				drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, 0x000000, 0.1);
			}
			
			
		}
		
	}
}