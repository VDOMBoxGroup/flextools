package PowerPack.com.gen.structs
{
	import PowerPack.com.gen.parse.parseClasses.ParsedBlock;
	import PowerPack.com.graph.NodeCategory;
	import PowerPack.com.graph.NodeType;
		
	public dynamic class NodeStruct
	{
		public var id:String;
		public var category:String;
		public var type:String;
		public var breakpoint:Boolean;
		public var enabled:Boolean;
		public var text:String;
		
		public var passCount:int = 0;
		public var graph:GraphStruct;
		
		[ArrayElementType("ArrowStruct")]
		public var outArrows:Array = [];
		
		[ArrayElementType("ArrowStruct")]
		public var inArrows:Array = [];
		
    	public function NodeStruct(	_id:String = null,
    								_category:String = null,
    								_type:String = null,
    								_text:String = "",
    								_enabled:Boolean = true,
    								_breakpoint:Boolean = false,
    								_graph:GraphStruct = null)
		{
			id = _id;
			category = _category?_category:NodeCategory.NORMAL;
			type = _type?_type:NodeType.NORMAL;
			text = _text;
			enabled = _enabled;
			breakpoint = _breakpoint;
			
			graph = _graph;
		}			
	}
}