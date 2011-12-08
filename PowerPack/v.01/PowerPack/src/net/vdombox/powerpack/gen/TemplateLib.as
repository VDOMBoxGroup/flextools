package net.vdombox.powerpack.gen
{
import net.vdombox.powerpack.lib.ExtendedAPI.codec.BMPEncoder;
import net.vdombox.powerpack.lib.ExtendedAPI.utils.FileToBase64;

import net.vdombox.powerpack.panel.Question;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.core.Application;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.utils.Base64Encoder;
import mx.utils.StringUtil;
import net.vdombox.powerpack.gen.parse.parseClasses.CodeFragment;

public dynamic class TemplateLib
{
	include "include/GeneralFunctions.as";
	include "include/ListManipulationFunctions.as";
	include "include/GraphicFunctions.as";
	include "include/ImageProcessingFunctions.as";
	include "include/ApplicationFunctions.as";

		
	public var tplStruct:TemplateStruct;
	
	private function setReturnValue(value:*):void
	{
		var lastFrag:CodeFragment = tplStruct.curNodeContext.block.lastExecutedFragment;
		
		lastFrag.retValue = value;
		tplStruct.context[lastFrag.retVarName] = value; 
		
		tplStruct.generate();
	}
	
	private function setTransition(value:String):void
	{
		var lastFrag:CodeFragment = tplStruct.curNodeContext.block.lastExecutedFragment;
		lastFrag.transition = value;
	}
	
	private function getContexts():Array
	{
		return [tplStruct.context, tplStruct.curGraphContext.context];	
	}
		
}
}