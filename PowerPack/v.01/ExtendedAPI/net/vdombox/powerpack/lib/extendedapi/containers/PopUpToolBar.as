package net.vdombox.powerpack.lib.ExtendedAPI.containers
{
import flash.events.MouseEvent;
import flash.display.DisplayObject;
import flash.geom.Point;
import mx.containers.TitleWindow;
import mx.containers.HBox;
import mx.core.*;
use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  Used internally by the Dockable ToolBar.
 */

public class PopUpToolBar extends TitleWindow
{

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function PopUpToolBar()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Called when the user stops dragging a Panel
	 *  that has been popped up by the PopUpManager.
	 */
	override protected function startDragging(event:MouseEvent):void
	{
	}

	/**
	 *  @private
	 *  Specialized layout for one child.
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
											   unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if (numChildren)
		{
			var child:IUIComponent = IUIComponent(getChildAt(0));
			child.setActualSize(unscaledWidth, child.getExplicitOrMeasuredHeight());
		}
	}
}
}
