package net.vdombox.powerpack.customize.skins
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import mx.skins.ProgrammaticSkin;
	
	public class BrowseBtnSkin extends ProgrammaticSkin
	{
		[Embed(source='assets/icons/BrowseBtnIcon.png')]
		private var backgroundImageClass :Class;
		
		[Embed(source='assets/icons/BrowseBtnIconOver.png')]
		private var backgroundImageOverClass :Class;
		
		private var backgroundImage :Bitmap;
		private var backgroundBitmapData :BitmapData;
		
		
		public function BrowseBtnSkin()
		{
			super();
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			graphics.clear();
			
			backgroundImage = (name == "downSkin" || name == "overSkin") ? new backgroundImageOverClass() : new backgroundImageClass();
			backgroundBitmapData = new BitmapData( backgroundImage.width, backgroundImage.height, true, 0x000000);
			backgroundBitmapData.draw( backgroundImage );
				
			graphics.clear();
			graphics.beginBitmapFill(backgroundBitmapData, null, false, true); 
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
	}
}