package net.vdombox.powerpack.lib.player.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class ControlBarBtnBorderSkin extends ProgrammaticSkin
	{
		public function ControlBarBtnBorderSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			graphics.clear();
			
			if (name == "downSkin")
			{
				graphics.beginFill(0x000000, 0.3);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			else if (name == "overSkin")
			{
				graphics.beginFill(0x000000, 0.15);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				graphics.endFill();
			}
			
		}
	}
}