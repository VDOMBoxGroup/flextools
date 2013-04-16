package net.vdombox.powerpack.lib.player.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class MinimizeButtonSkin extends ProgrammaticSkin
	{
		public function MinimizeButtonSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			graphics.clear();
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, 10, 10);
			graphics.endFill();
			
			graphics.moveTo(0.5, 9);
			graphics.lineStyle(2.5, 0xffffff);
			graphics.lineTo(9.5, 9);
			
		}
		
	}
}