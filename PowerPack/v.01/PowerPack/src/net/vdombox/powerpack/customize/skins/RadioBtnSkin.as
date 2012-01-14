package net.vdombox.powerpack.customize.skins
{
	import flash.display.GradientType;
	
	import mx.skins.Border;
	import mx.skins.ProgrammaticSkin;
	
	public class RadioBtnSkin extends Border
	{
		public function RadioBtnSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			var borderColor:uint = getStyle("borderColor");
			var borderThickness:uint = getStyle("borderThickness");
			var fillColor:uint = getStyle("fillColor");
			
			var r:Number = getStyle("iconRadius");
			graphics.clear();
			
			// RadioButton border
			graphics.beginGradientFill(GradientType.LINEAR, 
				[ borderColor, 0x000000 ], 
				[100,100], [0,0xFF], 
				verticalGradientMatrix(r/2,h/2,w,h));
			graphics.drawCircle(r/2,h/2,r);
			graphics.endFill();
			
			// RadioButton fill
			graphics.beginFill(fillColor);
			graphics.drawCircle(r/2,h/2,(r-borderThickness));
			graphics.endFill();
			
			if (name == "selectedUpSkin" || 
				name == "selectedOverSkin" || 
				name == "selectedDownSkin" ||
				name == "selectedDisabledSkin")
			{
				graphics.beginFill(0x000000);
				graphics.drawCircle(r/2,h/2,3.5);
				graphics.endFill();
			}
		}
	}
}