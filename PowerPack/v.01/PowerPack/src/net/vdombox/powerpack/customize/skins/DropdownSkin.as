package net.vdombox.powerpack.customize.skins
{
	import mx.skins.ProgrammaticSkin;
	
	public class DropdownSkin extends ProgrammaticSkin
	{
		public function DropdownSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void 
		{
			super.updateDisplayList(w, h);
			
			var cornerRadius					: Number = getStyle("cornerRadius");
			var borderColor						: int = getStyle("borderColor");
			var borderThickness					: Number = getStyle("borderThickness");
			var backgroundGradientColors		: Array = getStyle("backgroundGradientColors");
			
			graphics.clear();
			
			drawRoundRect(0-borderThickness, 0, w+2*borderThickness, h+2*borderThickness, cornerRadius, borderColor, 1);
			
			drawRoundRect(0, borderThickness, w, h, cornerRadius, backgroundGradientColors, 1, verticalGradientMatrix(0, 0, w, h));
			
			
		}
		
		
	}
}