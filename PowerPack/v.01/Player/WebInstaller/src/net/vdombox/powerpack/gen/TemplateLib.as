package net.vdombox.powerpack.gen
{

import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;

import net.vdombox.powerpack.events.TemplateLibEvents.TemplateLibEvent;
import net.vdombox.powerpack.gen.parse.parseClasses.CodeFragment;

public dynamic class TemplateLib extends EventDispatcher
{
	include "include/GeneralFunctions.as";
	include "include/ListManipulationFunctions.as";
	include "include/GraphicFunctions.as";
	include "include/ImageProcessingFunctions.as";
	include "include/ApplicationFunctions.as";
    include "include/XMLFunctions.as";


	public var tplStruct : TemplateStruct;

	
	private function setReturnValue( value : * ) : void
	{

		var lastFrag : CodeFragment = tplStruct.curNodeContext.block.lastExecutedFragment;

		lastFrag.retValue = value;
		tplStruct.context[lastFrag.retVarName] = value;

		tplStruct.generate();
	}

	private function setTransition( value : String ) : void
	{
		var lastFrag : CodeFragment = tplStruct.curNodeContext.block.lastExecutedFragment;
		lastFrag.transition = value;
	}

	private function getContexts() : Array
	{
		return [tplStruct.context, tplStruct.curGraphContext.context];
	}
	
	override public function dispatchEvent(event:Event):Boolean
	{
		return super.dispatchEvent(event);
	}
	
	
}
}