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

package modules
{

import flash.system.Capabilities;
import mx.controls.Image;
import mx.core.UIComponent;
import mx.states.SetProperty;
import mx.states.State;

/**
 *  The skin for the restore button in the TitleBar
 *  of a WindowedApplication or Window.
 * 
 *  @productversion Apollo 1.0
 */
public class ZzzzButtonSkin extends UIComponent
{  
    
	//--------------------------------------------------------------------------
	//
	//  Class assets
	//
	//--------------------------------------------------------------------------

    [Embed(source="assets/test/one.png")]
    private static var winRestoreUpSkin:Class;
    
	[Embed(source="assets/test/two.png")]
    private static var winRestoreDownSkin:Class;
    
    [Embed(source="assets/test/two.png")]
    private static var winRestoreOverSkin:Class;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function ZzzzButtonSkin()
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
		upProp.value = winRestoreUpSkin;
		upState.overrides.push(upProp);
		states.push(upState);
		
		var downState:State = new State();
		downState.name = "down";
		var downProp:SetProperty = new SetProperty();
		downProp.name = "source";
		downProp.target = skinImage;
		downProp.value = winRestoreDownSkin;
		downState.overrides.push(downProp);
		states.push(downState);
		
		var overState:State = new State();
		overState.name = "over";
		var overProp:SetProperty = new SetProperty();
		overProp.name = "source";
		overProp.target = skinImage;
		overProp.value = winRestoreOverSkin;
		overState.overrides.push(overProp);
		states.push(overState);
		
		var selectedUpState:State = new State();
		selectedUpState.name = "selectedUp";
		var selectedUpProp:SetProperty = new SetProperty();
		selectedUpProp.name = "source";
		selectedUpProp.target = skinImage;
		selectedUpProp.value = winRestoreUpSkin;
		selectedUpState.overrides.push(selectedUpProp);
		states.push(selectedUpState);
		
		var selectedDownState:State = new State();
		selectedDownState.name = "selectedDown";
		var selectedDownProp:SetProperty = new SetProperty();
		selectedDownProp.name = "source";
		selectedDownProp.target = skinImage;
		selectedDownProp.value = winRestoreUpSkin;
		selectedDownState.overrides.push(selectedDownProp);
		states.push(selectedDownState);
		
		var selectedOverState:State = new State();
		selectedOverState.name = "selectedOver";
		var selectedOverProp:SetProperty = new SetProperty();
		selectedOverProp.name = "source";
		selectedOverProp.target = skinImage;
		selectedOverProp.value = winRestoreUpSkin;
		selectedOverState.overrides.push(selectedOverProp);
		states.push(selectedOverState);
	}
}

}
