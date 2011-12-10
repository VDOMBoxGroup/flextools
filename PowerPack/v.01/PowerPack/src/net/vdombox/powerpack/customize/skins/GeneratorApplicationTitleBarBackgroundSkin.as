package net.vdombox.powerpack.customize.skins
{

import mx.core.IWindow;
import mx.core.UIComponent;
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
	override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
	{
		super.updateDisplayList( unscaledWidth, unscaledHeight );

		var cornerRadius : Number = getStyle( "cornerRadius" );
		var titleBarColors : Array = getStyle( "titleBarColors" );
		var borderThickness : Number = UIComponent( parent.parent ).getStyle( "borderThickness" );
		var isActiveWindow : Boolean = IWindow( parent.parent ).nativeWindow.active;

		StyleManager.getColorNames( titleBarColors );
		graphics.clear();

		drawRoundRect(
				0 - borderThickness + 1, 0 - borderThickness, unscaledWidth + borderThickness * 2 - 2, unscaledHeight + borderThickness,
				{tl : cornerRadius,
					tr : cornerRadius, bl : 0, br : 0},
				isActiveWindow ? titleBarColors[1] : titleBarColors[1], [1.0],
				verticalGradientMatrix( 0, 0, unscaledWidth, unscaledHeight ) );

		drawRoundRect(
				0 - borderThickness + 4, 0 - borderThickness + 2, unscaledWidth + borderThickness * 2 - 8, unscaledHeight / 2,
				{tl : cornerRadius / 1.2,
					tr : cornerRadius / 1.2, bl : 0, br : 0},
				titleBarColors[0], [0.4],
				verticalGradientMatrix( 0, 0, unscaledWidth, unscaledHeight / 2 ) );

	}
}

}
