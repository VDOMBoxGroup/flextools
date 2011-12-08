package net.vdombox.powerpack.com.gen
{
import net.vdombox.powerpack.com.gen.parse.parseClasses.ParsedBlock;
import net.vdombox.powerpack.com.gen.structs.NodeStruct;

public class NodeContext
{
	public var node:NodeStruct;
	public var block:ParsedBlock;
	
	public function NodeContext(_node:NodeStruct, _block:ParsedBlock)
	{
		node = _node;
		block = _block;
	}
}
}