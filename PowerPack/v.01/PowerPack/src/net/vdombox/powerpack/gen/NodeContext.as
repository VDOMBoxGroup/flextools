package net.vdombox.powerpack.gen
{

import net.vdombox.powerpack.gen.parse.parseClasses.ParsedBlock;
import net.vdombox.powerpack.gen.structs.NodeStruct;

public class NodeContext
{
	public var node : NodeStruct;
	public var block : ParsedBlock;

	public function NodeContext( _node : NodeStruct, _block : ParsedBlock )
	{
		node = _node;
		block = _block;
	}
}
}