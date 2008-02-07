package PowerPack.com.gen
{
	import PowerPack.com.gen.*;
	import PowerPack.com.graph.GraphNodeCategory;
	import PowerPack.com.graph.GraphNodeType;
		
	public class NodeStruct
	{
		public var id:String;
		public var category:String;
		public var type:String;
		public var text:String;
		
		public var graph:GraphStruct;
		
		[ArrayElementType("ArrowStruct")]
		public var outArrows:Array;
		
		[ArrayElementType("ArrowStruct")]
		public var inArrows:Array;	
    	
    	public function NodeStruct(	_id:String = null,
    								_category:String = null,
    								_type:String = null,
    								_text:String = "",
    								_graph:GraphStruct = null)
		{
			id = _id;
			category = _category?_category:GraphNodeCategory.NORMAL;
			type = _type?_type:GraphNodeType.NORMAL;
			text = _text;
			
			graph = _graph;
			
			outArrows = new Array();
			inArrows = new Array();
		}			
	}
}