package net.vdombox.powerpack.lib.player.gen.structs
{

import net.vdombox.powerpack.lib.player.graph.NodeCategory;
import net.vdombox.powerpack.lib.player.graph.NodeType;

public dynamic class NodeStruct
{
	public var id : String;
	public var category : String;
	public var type : String;
	public var breakpoint : Boolean;
	public var enabled : Boolean;
	private var _text : String;

	public var passCount : int = 0;
	public var graph : GraphStruct;

	[ArrayElementType("net.vdombox.powerpack.lib.player.gen.structs.ArrowStruct")]
	public var outArrows : Array = [];

	[ArrayElementType("net.vdombox.powerpack.lib.player.gen.structs.ArrowStruct")]
	public var inArrows : Array = [];

	public function NodeStruct( _id : String = null, _category : String = null, _type : String = null, _text : String = "", _enabled : Boolean = true, _breakpoint : Boolean = false, _graph : GraphStruct = null )
	{
		id = _id;
		category = _category ? _category : NodeCategory.NORMAL;
		type = _type ? _type : NodeType.NORMAL;
		text = _text;
		enabled = _enabled;
		breakpoint = _breakpoint;

		graph = _graph;
	}

	public function get text():String
	{
		if ( category == NodeCategory.NORMAL)
			return _text;
		
		return _text.replace(/\r/g, "");
	}

	public function set text(value:String):void
	{
		
		_text = value ? value : "";
		 
	}

}
}