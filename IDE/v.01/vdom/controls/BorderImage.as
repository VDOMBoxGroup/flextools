package vdom.controls
{

import mx.controls.Image;

[Style(name="borderColor", type="uint", format="Color", inherit="no")]
[Style(name="borderThickness", type="Number", format="Length", inherit="no")]
[Style(name="borderAlpha", type="Number", format="Length", inherit="no")]

public class BorderImage extends Image 
{
	public function BorderImage()
	{
		super();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var borderThickness:Number = getStyle('borderThickness');
		
		//x+=(borderThickness/2);
		//y+=(borderThickness/2);
		
		graphics.lineStyle(
			getStyle('borderThickness'),
			getStyle('borderColor'),
			getStyle('borderAlpha'),
			false
		);
		
//		var newWidth:Number = contentWidth ? contentWidth + borderThickness : borderThickness;
//		var newHeight:Number = contentHeight ? contentHeight + borderThickness : borderThickness; 
		
		var newWidth:Number = unscaledWidth + borderThickness;
		var newHeight:Number = unscaledHeight + borderThickness;
		
		graphics.drawRect(
			-(borderThickness/2),
			-(borderThickness/2),
			newWidth,
			newHeight
		);
	}
}
}