package net.vdombox.powerpack.lib.player.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class CloseButtonSkin extends ProgrammaticSkin
	{
		public function CloseButtonSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			graphics.clear();
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, 10, 10);
			graphics.endFill();
			
			graphics.moveTo(1.5, 1.5);
			graphics.lineStyle(2.5, 0xffffff);
			graphics.lineTo(8.5, 8.5);
			
			graphics.moveTo(8.5, 1.5);
			graphics.lineStyle(2.5, 0xffffff);
			graphics.lineTo(1.5, 8.5);
			
		}
		
	}
}