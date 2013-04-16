package net.vdombox.powerpack.lib.player.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class BrowseButtonSkin extends ProgrammaticSkin
	{
		public function BrowseButtonSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var cornerRadius : Number = getStyle("cornerRadius");
			var fillColors : Array = getStyle("fillColors");
			var borderColors : Array = getStyle("borderColors");
			
			graphics.clear();
			
			drawRoundRect(0, 0, unscaledWidth, unscaledHeight, cornerRadius, borderColors, 1,
						verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));
			
			drawRoundRect(1, 1, unscaledWidth-2, unscaledHeight-2, cornerRadius, fillColors, 1, 
				verticalGradientMatrix(1, 1, unscaledWidth-2, unscaledHeight-2));
			
			
			if (name == "downSkin" || name == "overSkin")
			{
				drawRoundRect(1, 1, unscaledWidth-2, unscaledHeight-2, cornerRadius, 0x000000, 0.1);
			}
			
		}
		
	}
}