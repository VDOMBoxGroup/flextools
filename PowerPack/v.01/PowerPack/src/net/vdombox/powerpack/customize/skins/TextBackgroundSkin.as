package net.vdombox.powerpack.customize.skins
{
	import flash.display.GradientType;
	
	import mx.skins.ProgrammaticSkin;
	
	public class TextBackgroundSkin extends ProgrammaticSkin
	{
		public function TextBackgroundSkin()
		{
			super();
		}
		
		override protected function updateDisplayList( w : Number, h : Number ) : void
		{
			super.updateDisplayList( w, h );
			
			graphics.clear();
			
			graphics.beginGradientFill(GradientType.LINEAR, 
				[ 0xff0000, 0x00ff00 ], 
				[100,100], [0,0xFF], 
				verticalGradientMatrix(0,0,w,h));
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
		}
		
		
	}
}