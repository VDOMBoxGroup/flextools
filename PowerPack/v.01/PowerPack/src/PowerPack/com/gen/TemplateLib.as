package PowerPack.com.gen
{
import ExtendedAPI.com.graphics.codec.BMPEncoder;
import ExtendedAPI.com.utils.FileToBase64;

import PowerPack.com.panel.Question;

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

public dynamic class TemplateLib
{
	//include "include/GeneralFunctions.as";
	//include "include/ListManipulationFunctions.as";
	//include "include/GraphicFunctions.as";
	//include "include/ImageProcessingFunctions.as";
		
	public var tplStruct:TemplateStruct;
	
	public function TemplateLib()
	{
	}
	
	public function setReturnValue(value:*):void
	{
		tplStruct.parsedNode.value = value;
	}
}
}