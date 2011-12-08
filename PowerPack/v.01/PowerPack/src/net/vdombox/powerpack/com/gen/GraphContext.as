package net.vdombox.powerpack.com.gen
{
	import net.vdombox.powerpack.com.gen.structs.*;
	
	public class GraphContext
	{
		public var curGraph:GraphStruct;
		public var curNode:NodeStruct;
		public var buffer:String;
		public var varPrefix:String;
		public var context:Dynamic;
		public var contextStack:Array = [];
		
		public function GraphContext(	_curGraph:GraphStruct,
										_curNode:NodeStruct = null,
										_variable:String = null,
										_varPrefix:String = "")
		{
			curGraph = _curGraph; // current graph
			curNode = _curNode ? _curNode : curGraph.initNode; // current node
			buffer = ""; // output data buffer
			varPrefix = _varPrefix; // left-part variable prefix
			context = new Dynamic();
		}
	}
}