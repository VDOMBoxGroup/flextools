package vdom.skins {

// Import necessary classes here.
import flash.display.Graphics;
import mx.skins.Border;
import mx.skins.ProgrammaticSkin;
import mx.styles.StyleManager;
import flash.display.GradientType;

public class ActionPanelBackground extends ProgrammaticSkin {

	public var _backgroundFillColor:Number;
	public var _lineThickness:Number;
	
	// Constructor.
	public function ButtonStylesSkin():void {
		// Set default values.
		_backgroundFillColor = 0xFFFFFF;
		_lineThickness=2;
	}
	
	override protected function updateDisplayList(w:Number, h:Number):void {
		
		if (getStyle("backgroundFillColor")) {
			// Get value of backgroundFillColor style property.
			_backgroundFillColor = getStyle("backgroundFillColor");
		}
	
		// Draw the box using the new values.
		var g:Graphics = graphics;
		g.clear();
		g.beginGradientFill(GradientType.LINEAR, [0xff0000, 0x00ff00], [1, 1], [0, 255]);
		g.lineStyle(_lineThickness, 0xFF0000);
		g.drawRect(0, 0, w, h);
		g.endFill();
		g.moveTo(0, 0);
		g.lineTo(w, h);
		g.moveTo(0, h);
		g.lineTo(w, 0);
	}
}
}