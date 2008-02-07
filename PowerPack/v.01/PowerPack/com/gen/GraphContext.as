package PowerPack.com.gen
{
	import PowerPack.com.gen.*;
	
	public class GraphContext
	{
		public var curGraph:GraphStruct;
		public var curNode:NodeStruct;
		public var buffer:String;
		public var varPrefix:String;
		public var resultVar:String;
		
		public function GraphContext(	_curGraph:GraphStruct,
										_curNode:NodeStruct = null,
										_resultVar:String = null,
										_varPrefix:String = "")
		{
			curGraph = _curGraph; // current graph
			curNode = _curNode ? _curNode : curGraph.initNode; // current node
			buffer = ""; // output data buffer
			varPrefix = _varPrefix; // left-part variable prefix
			resultVar = _resultVar; // variable name for storing output data
		}
	}
}