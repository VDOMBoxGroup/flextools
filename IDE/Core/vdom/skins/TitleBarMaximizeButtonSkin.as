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
import mx.controls.Image;
import mx.core.UIComponent;
import mx.states.SetProperty;
import mx.states.State;

/**
 *  The skin for the maximize button in the TitleBar
 *  of a WindowedApplication or Window.
 * 
 *  @productversion Apollo 1.0
 */
public class TitleBarMaximizeButtonSkin extends UIComponent
{
    
	//--------------------------------------------------------------------------
	//
	//  Class assets
	//
	//--------------------------------------------------------------------------

	[Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinUp")]
    private static var macMaxUpSkin:Class;

    [Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinUp")]
    private static var winMaxUpSkin:Class;
	   
	[Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinOver")]
	private static var macMaxOverSkin:Class;
	
	[Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinOver")]
	private static var winMaxOverSkin:Class;

  	[Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinDown")]
    private static var macMaxDownSkin:Class;

    [Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinDown")]
    private static var winMaxDownSkin:Class;
    
    [Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinUp")]
    private static var macMaxDisabledSkin:Class;

    [Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="maximizeButtonSkinUp")]
    private static var winMaxDisabledSkin:Class;
    
    [Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="restoreButtonSkinUp")]
    private static var winRestoreUpSkin:Class;
    
   	[Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="restoreButtonSkinDown")]
    private static var winRestoreDownSkin:Class;
    
    [Embed(source="/assets/titleBarButtons/titleBarButtons.swf", symbol="restoreButtonSkinOver")]
    private static var winRestoreOverSkin:Class;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function TitleBarMaximizeButtonSkin()
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
			return 21;
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

		skinImage.setActualSize(21, 16);
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
		upProp.value = isMac ? macMaxUpSkin : winMaxUpSkin;
		upState.overrides.push(upProp);
		states.push(upState);
		
		var downState:State = new State();
		downState.name = "down";
		var downProp:SetProperty = new SetProperty();
		downProp.name = "source";
		downProp.target = skinImage;
		downProp.value = isMac ? macMaxDownSkin : winMaxDownSkin;
		downState.overrides.push(downProp);
		states.push(downState);
		
		var overState:State = new State();
		overState.name = "over";
		var overProp:SetProperty = new SetProperty();
		overProp.name = "source";
		overProp.target = skinImage;
		overProp.value = isMac ? macMaxOverSkin : winMaxOverSkin;
		overState.overrides.push(overProp);
		states.push(overState);
		
		var disabledState:State = new State();
		disabledState.name = "disabled";
		var disabledProp:SetProperty = new SetProperty();
		disabledProp.name = "source";
		disabledProp.target = skinImage;
		disabledProp.value = isMac ? macMaxDisabledSkin : winMaxDisabledSkin;
		disabledState.overrides.push(disabledProp);
		states.push(disabledState);
	}
}

}
