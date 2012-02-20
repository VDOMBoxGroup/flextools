package net.vdombox.powerpack.lib.player.gen
{

import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.ParsedBlock;
import net.vdombox.powerpack.lib.player.gen.structs.NodeStruct;

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