package net.vdombox.powerpack.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class MaximizeButtonSkin extends ProgrammaticSkin
	{
		public function MaximizeButtonSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			graphics.clear();
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, 10, 10);
			graphics.endFill();
			
			graphics.moveTo(0.5, 1);
			graphics.lineStyle(2, 0xffffff);
			graphics.lineTo(9, 1);
			
			graphics.moveTo(0.5, 9);
			graphics.lineStyle(1, 0xffffff);
			graphics.lineTo(9.5, 9);
			
			graphics.moveTo(9.5, 2);
			graphics.lineStyle(1, 0xffffff);
			graphics.lineTo(9.5, 10);
			
			graphics.moveTo(0.5, 2);
			graphics.lineStyle(1, 0xffffff);
			graphics.lineTo(0.5, 10);
			
		}
		
	}
}