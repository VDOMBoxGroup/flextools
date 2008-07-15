package PowerPack.com.gen.structs
{
	public class ArrowStruct
	{
		public var id:String;
		public var data:Object;
		public var label:String;
		
		public var fromObj:NodeStruct;
		public var toObj:NodeStruct;
		
		public var graph:GraphStruct;
		
    	public function ArrowStruct(	_id:String = null,
    									_label:String = "",
    									_fromObj:NodeStruct = null, 
    									_toObj:NodeStruct = null,
    									_graph:GraphStruct = null)
		{
			id = _id;
			label = _label;
			
			fromObj = _fromObj;
			toObj = _toObj;
			
			graph = _graph;			
		}
	}
}