package src.net.vdombox.powerpack.lib.extendedapi.containers
{
import src.net.vdombox.powerpack.lib.extendedapi.containers.utilityClasses.AdobeFlowLayout;

import mx.core.Container;
import mx.core.mx_internal;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Number of pixels between children in the horizontal direction.
 */
[Style(name="horizontalGap", type="Number", format="Length", inherit="no")]

/**
 *  Number of pixels between children in the vertical direction.
 */
[Style(name="verticalGap", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusIn", kind="event")]
[Exclude(name="focusOut", kind="event")]

[Exclude(name="focusBlendMode", kind="style")]
[Exclude(name="focusSkin", kind="style")]
[Exclude(name="focusThickness", kind="style")]

[Exclude(name="focusInEffect", kind="effect")]
[Exclude(name="focusOutEffect", kind="effect")]

/**
 *  The FlowContainer is a flow layout based container.
 *  
 */

public class FlowContainer extends Container
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function FlowContainer()
	{
		super();
		horizontalScrollPolicy = "off";
		layoutObject.target = this;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	mx_internal var layoutObject:AdobeFlowLayout = new AdobeFlowLayout();

	//--------------------------------------------------------------------------
	//
	//  Overridden properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override public function set height(newHeight:Number):void
	{
		layoutObject.explicitHeightSet = true;
		super.height = newHeight;
	}
	
	/**
	 *  @private
	 */
	override protected function measure():void
	{
		super.measure();
		layoutObject.measure();
	}

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		layoutObject.updateDisplayList(unscaledWidth, unscaledHeight);
    }
    
}

}
