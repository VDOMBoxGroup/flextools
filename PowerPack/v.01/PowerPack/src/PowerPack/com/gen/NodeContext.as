package PowerPack.com.gen
{
import PowerPack.com.gen.structs.NodeStruct;

public class NodeContext
{
	public var node:NodeStruct;
	public var parsedNode:ParsedNode;
	
	public function NodeContext(_node:NodeStruct)
	{
		node = _node;
	}
}
}