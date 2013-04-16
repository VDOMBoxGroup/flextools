package net.vdombox.powerpack.customize.core.windowClasses
{

import flash.events.Event;

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.core.windowClasses.TitleBar;

import net.vdombox.powerpack.lib.player.customize.skins.MinimizeButtonSkin;

use namespace mx_internal;

public class GeneratorTitleBar extends TitleBar
{
	private var bgButtons : UIComponent;

	public function GeneratorTitleBar()
	{
		super();
	}

	private function onActivate( event : Event ) : void
	{
		styleChanged( "titleBarBackgroundSkin" );
	}

	private function onDeactivate( event : Event ) : void
	{
		styleChanged( "titleBarBackgroundSkin" );
	}

	protected override function placeButtons( align : String, unscaledWidth : Number, unscaledHeight : Number, leftOffset : Number, rightOffset : Number, cornerOffset : Number ) : void
	{
		var pad : Number = getStyle( "buttonPadding" );
		var edgePad : Number = getStyle( "titleBarButtonPadding" );

		minimizeButton.setActualSize( minimizeButton.measuredWidth,
				minimizeButton.measuredHeight );
		
		maximizeButton.setActualSize( maximizeButton.measuredWidth,
				maximizeButton.measuredHeight );
		
		closeButton.setActualSize( closeButton.measuredWidth,
				closeButton.measuredHeight );
		
		if ( align == "right" )
		{
			closeButton.move(
				unscaledWidth - closeButton.measuredWidth -
				3*cornerOffset - edgePad,
				edgePad );
			
			maximizeButton.move(
					closeButton.x - 10 - edgePad,
					edgePad );

			minimizeButton.move(
				maximizeButton.x - 10 - edgePad,
				edgePad );

		}
		else
		{
			edgePad = Math.max( edgePad, leftOffset );

			closeButton.move(
					edgePad,
					edgePad );

			minimizeButton.move(
					pad + edgePad + closeButton.measuredWidth,
					edgePad );

			maximizeButton.move(
					edgePad + (pad * 2) +
							closeButton.measuredWidth + minimizeButton.measuredWidth,
					edgePad );
		}
	}

	override protected function createChildren() : void
	{
		super.createChildren();
		if ( !bgButtons )
		{
			bgButtons = new UIComponent();
			addChildAt( bgButtons, getChildIndex( minimizeButton ) );

			//parent.addEventListener(Event.ACTIVATE, onActivate);
			//parent.addEventListener(Event.DEACTIVATE, onDeactivate);
		}

	}

	override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
	{
		var cornerRadius1 : Number = getStyle( "cornerRadius" ) / 1.7;
		var cornerRadius2 : Number = getStyle( "cornerRadius" ) / 2;

		var titleBarButtonBgColors : Array = getStyle( "titleBarButtonBgColors" );

		var pad : Number = getStyle( "buttonPadding" );

		var leftButtonsBg : Number = Math.min( minimizeButton.x, maximizeButton.x, closeButton.x ) - pad;
		var topButtonsBg : Number = Math.min( minimizeButton.y, maximizeButton.y, closeButton.y );
		var rightButtonsBg : Number = Math.max( minimizeButton.x + minimizeButton.width,
				maximizeButton.x + maximizeButton.width, closeButton.x + closeButton.width ) + pad;
		var bottomButtonsBg : Number = Math.max( minimizeButton.y + minimizeButton.height,
				maximizeButton.y + maximizeButton.height, closeButton.y + closeButton.height );

		if ( bgButtons )
		{
			bgButtons.graphics.clear();

			if ( titleBarButtonBgColors && titleBarButtonBgColors.length > 0 )
				bgButtons.drawRoundRect(
						leftButtonsBg, topButtonsBg,
						rightButtonsBg - leftButtonsBg, bottomButtonsBg - topButtonsBg,
						{tl : cornerRadius1,
							tr : cornerRadius1, bl : 0, br : 0},
						titleBarButtonBgColors[0], [1.0],
						verticalGradientMatrix( 0, 0, unscaledWidth, unscaledHeight ) );

			if ( titleBarButtonBgColors && titleBarButtonBgColors.length > 1 )
				bgButtons.drawRoundRect(
						leftButtonsBg + 2, topButtonsBg + 1,
						rightButtonsBg - leftButtonsBg - 4, (bottomButtonsBg - topButtonsBg) / 2,
						{tl : cornerRadius2,
							tr : cornerRadius2, bl : 0, br : 0},
						titleBarButtonBgColors[1], [0.6],
						verticalGradientMatrix( 0, 0, unscaledWidth, unscaledHeight ) );
		}
		
		super.updateDisplayList( unscaledWidth, unscaledHeight );
	}
	
}
}