package PowerPack.customize.skins
{

import mx.skins.ProgrammaticSkin;
import mx.styles.StyleManager;

/**
 *  The skin for the TitleBar of a WindowedApplication or Window.
 */
public class GeneratorApplicationTitleBarBackgroundSkin extends ProgrammaticSkin
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function GeneratorApplicationTitleBarBackgroundSkin()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Programmatic Skin
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
									  			  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var cornerRadius:Number = getStyle("cornerRadius");
		var titleBarColors:Array = getStyle("titleBarColors");

		StyleManager.getColorNames(titleBarColors);
		graphics.clear();

		drawRoundRect(
			0, 0, unscaledWidth, unscaledHeight, {tl: cornerRadius, 
			tr: cornerRadius, bl: 0, br: 0},
			titleBarColors[1], [1.0],
			verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));

		drawRoundRect(
			0, 0, unscaledWidth, unscaledHeight/2, {tl: cornerRadius, 
			tr: cornerRadius, bl: 0, br: 0},
			titleBarColors[0], [0.4],
			verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight/2));
		
		graphics.lineStyle(2, titleBarColors[1], 1.0);
		graphics.moveTo(0, unscaledHeight - 1);
		graphics.lineTo(0, cornerRadius);
		graphics.curveTo(0, 0, cornerRadius, 0);
		graphics.lineTo(unscaledWidth - cornerRadius, 0);
		graphics.curveTo(unscaledWidth, 0, unscaledWidth, cornerRadius);
		graphics.lineTo(unscaledWidth, unscaledHeight - 1);
		graphics.moveTo(0, unscaledHeight - 1);
		
		graphics.lineStyle(2, titleBarColors[1], 1.0);
		graphics.lineTo(unscaledWidth, unscaledHeight - 1);
		
	}
}

}
