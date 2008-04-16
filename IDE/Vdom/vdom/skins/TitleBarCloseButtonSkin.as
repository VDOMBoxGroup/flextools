////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package vdom.skins
{

import flash.system.Capabilities;
import mx.core.UIComponent;
import mx.controls.Image;
import mx.states.SetProperty;
import mx.states.State;

/**
 *  The skin for the close button in the TitleBar
 *  of a WindowedApplication or Window.
 * 
 *  @productversion Apollo 1.0
 */
public class TitleBarCloseButtonSkin extends UIComponent
{
    
	//--------------------------------------------------------------------------
	//
	//  Class assets
	//
	//--------------------------------------------------------------------------

	[Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinUp")]
    private static var macCloseUpSkin:Class;

    [Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinUp")]
    private static var winCloseUpSkin:Class;
	   
	[Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinOver")]
	private static var macCloseOverSkin:Class;
	
	[Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinOver")]
	private static var winCloseOverSkin:Class;

  	[Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinDown")]
    private static var macCloseDownSkin:Class;

    [Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinDown")]
    private static var winCloseDownSkin:Class;
	
	[Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinUp")]
    private static var macCloseDisabledSkin:Class;

    [Embed(source="assets/titleBarButtons/titleBarButtons.swf", symbol="closeButtonSkinUp")]
    private static var winCloseDisabledSkin:Class;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function TitleBarCloseButtonSkin()
	{
		super();

		isMac = Capabilities.os.substring(0,3) == "Mac";
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var isMac:Boolean;
	
	/**
	 *  @private
	 */
	private var skinImage:Image;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties: UIComponent
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  measuredHeight
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredHeight():Number
	{
		if (skinImage.measuredHeight)
			return skinImage.measuredHeight;
		else
			return 16;
	}

	//----------------------------------
	//  measuredWidth
	//----------------------------------

	/**
	 *  @private
	 */
	override public function get measuredWidth():Number
	{
		if (skinImage.measuredWidth)
			return skinImage.measuredWidth;
		else
			return 24;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function createChildren():void
	{
		skinImage = new Image();
		addChild(skinImage);

		initializeStates();

		skinImage.setActualSize(24, 16);
		skinImage.move(0, 0);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function initializeStates():void
	{
		var upState:State = new State();
		upState.name = "up";
		var upProp:SetProperty = new SetProperty();
		upProp.name = "source";
		upProp.target = skinImage;
		upProp.value = isMac ? macCloseUpSkin : winCloseUpSkin;
		upState.overrides.push(upProp);
		states.push(upState);
		
		var downState:State = new State();
		downState.name = "down";
		var downProp:SetProperty = new SetProperty();
		downProp.name = "source";
		downProp.target = skinImage;
		downProp.value = isMac ? macCloseDownSkin : winCloseDownSkin;
		downState.overrides.push(downProp);
		states.push(downState);
		
		var overState:State = new State();
		overState.name = "over";
		var overProp:SetProperty = new SetProperty();
		overProp.name = "source";
		overProp.target = skinImage;
		overProp.value = isMac ? macCloseOverSkin : winCloseOverSkin;
		overState.overrides.push(overProp);
		states.push(overState);
		
		var disabledState:State = new State();
		disabledState.name = "disabled";
		var disabledProp:SetProperty = new SetProperty();
		disabledProp.name = "source";
		disabledProp.target = skinImage;
		disabledProp.value = isMac ? macCloseDisabledSkin : winCloseDisabledSkin;
		disabledState.overrides.push(disabledProp);
		states.push(disabledState);
	}
}

}
