package net.vdombox.powerpack.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	import mx.states.SetStyle;
	
	public class RoundButtonSkin extends ProgrammaticSkin
	{
		
		[Embed(source='assets/icons/RoundBtnIcon.png')]
		private var backgroundImageClass :Class;
		
		[Embed(source='assets/icons/RoundBtnIconOver.png')]
		private var backgroundImageOverClass :Class;
		
		private var backgroundImage :Bitmap;
		private var backgroundBitmapData :BitmapData;
		
		
		public function RoundButtonSkin()
		{
			super();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			graphics.clear();
			
			var imageWidth:Number = 74;
			var imageX : Number = (unscaledWidth-74)/2;
			
			backgroundImage = (name == "downSkin" || name == "overSkin") ? new backgroundImageOverClass() : new backgroundImageClass();
			backgroundBitmapData = new BitmapData( imageWidth, backgroundImage.height, true, 0x000000);
			backgroundBitmapData.draw( backgroundImage );
			
			graphics.clear();
			graphics.beginBitmapFill(backgroundBitmapData, null, false, true); 
			graphics.drawRect(imageX, 0, imageWidth, unscaledHeight);
			graphics.endFill();
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		
	}
}