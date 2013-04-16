package net.vdombox.powerpack.customize.core.windowClasses
{

import flash.display.DisplayObject;

import mx.containers.HBox;
import mx.core.IFlexDisplayObject;
import mx.core.IUITextField;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.core.mx_internal;
import mx.styles.ISimpleStyleClient;
import mx.styles.IStyleClient;
import mx.utils.StringUtil;

use namespace mx_internal;

/**
 *  The default status bar for a WindowedApplication or a Window.
 */
public class SuperStatusBar extends UIComponent
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function SuperStatusBar() : void
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  A reference to the status bar's skin.
	 */
	mx_internal var statusBarBackground : IFlexDisplayObject;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  status
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the status property.
	 */
	private var _status : String = "";

	/**
	 *  @private
	 */
	private var statusChanged : Boolean = false;

	/**
	 *  The string that appears in the status bar, if it is visible.
	 *
	 *  @default ""
	 */
	public function get status() : String
	{
		return _status;
	}

	/**
	 *  @private
	 */
	public function set status( value : String ) : void
	{
		_status = value;
		statusChanged = true;

		invalidateProperties();
		invalidateSize();
	}

	//----------------------------------
	//  statusHBox
	//----------------------------------

	public var statusHBox : HBox;

	//----------------------------------
	//  statusTextField
	//----------------------------------

	/**
	 *  A reference to the UITextField that displays the status bar's text.
	 */
	public var statusTextField : IUITextField;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function createChildren() : void
	{
		super.createChildren();

		var statusBarBackgroundClass : Class =
				getStyle( "statusBarBackgroundSkin" );
		if ( statusBarBackgroundClass )
		{
			statusBarBackground = new statusBarBackgroundClass();
			var backgroundUIComponent : IStyleClient =
					statusBarBackground as IStyleClient;
			if ( backgroundUIComponent )
			{
				backgroundUIComponent.setStyle( "backgroundImage",
						undefined );
			}
			var backgroundStyleable : ISimpleStyleClient =
					statusBarBackground as ISimpleStyleClient;
			if ( backgroundStyleable )
				backgroundStyleable.styleName = this;
			addChild( DisplayObject( statusBarBackground ) );
		}

		if ( !statusHBox )
		{
			statusHBox = new HBox();
			statusHBox.autoLayout = true;
			statusHBox.horizontalScrollPolicy = "false";
			statusHBox.verticalScrollPolicy = "false";
			statusHBox.setStyle( "verticalAlign", "middle" );
			addChild( statusHBox );
		}
		if ( !statusTextField )
		{
			statusTextField = IUITextField( createInFontContext( UITextField ) );
			statusTextField.text = _status;
			statusTextField.styleName = getStyle( "statusTextStyleName" );
			statusTextField.enabled = true;
			statusHBox.addChild( DisplayObject( statusTextField ) );
		}
	}

	/**
	 *  @private
	 */
	override protected function commitProperties() : void
	{
		super.commitProperties();

		if ( statusChanged )
		{
			statusTextField.text = _status;
			statusChanged = false;

			if ( !statusTextField.text || !StringUtil.trim( statusTextField.text ) )
			{
				statusTextField.visible = false;
				statusTextField.includeInLayout = false;
			}
			else
			{
				statusTextField.visible = true;
				statusTextField.includeInLayout = true;
			}
		}
	}

	/**
	 *  @private
	 */
	override protected function measure() : void
	{
		super.measure();

		statusHBox.validateNow();

		statusTextField.validateNow();
		if ( statusTextField.textHeight == 0 )
		{
			statusTextField.text = " ";
			statusTextField.validateNow();
		}

		measuredHeight = statusTextField.textHeight +
				UITextField.TEXT_HEIGHT_PADDING;
		measuredWidth = statusTextField.textWidth;
	}

	/**
	 *  @private
	 */
	override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
	{
		super.updateDisplayList( unscaledWidth, unscaledHeight );

		statusBarBackground.setActualSize( unscaledWidth, unscaledHeight );
		statusHBox.height = unscaledHeight;
		statusHBox.width = unscaledWidth;

		statusHBox.validateNow();

		statusTextField.text = _status;
		if ( statusTextField.x + statusTextField.textWidth > unscaledWidth )
		{
			statusTextField.width = Math.max( 0, unscaledWidth - statusTextField.x );
			statusTextField.truncateToFit( "..." );
		}
	}

	/**
	 *  @private
	 */
	override public function styleChanged( styleProp : String ) : void
	{
		super.styleChanged( styleProp );
		
		invalidateDisplayList();

		var allStyles : Boolean = !styleProp || styleProp == "styleName";

		if ( allStyles || styleProp == "statusBarBackgroundSkin" )
		{
			var statusBarBackgroundClass : Class =
					getStyle( "statusBarBackgroundSkin" );
			if ( statusBarBackgroundClass )
			{
				if ( statusBarBackground )
				{
					removeChild( DisplayObject( statusBarBackground ) );
					statusBarBackground = null;
				}
				statusBarBackground = new statusBarBackgroundClass();
				var backgroundUIComponent : IStyleClient =
						statusBarBackground as IStyleClient;
				if ( backgroundUIComponent )
				{
					backgroundUIComponent.setStyle( "backgroundImage",
							undefined );
				}
				var backgroundStyleable : ISimpleStyleClient =
						statusBarBackground as ISimpleStyleClient;
				if ( backgroundStyleable )
					backgroundStyleable.styleName = this;
				addChildAt( DisplayObject( statusBarBackground ), 0 );
			}
		}

		if ( allStyles || styleProp == "statusTextStyleName" )
		{
			if ( statusTextField )
				statusTextField.styleName = getStyle( "statusTextStyleName" );
		}
	}
}

}
