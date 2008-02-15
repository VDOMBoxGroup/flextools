package PowerPack.com.gen
{
	import PowerPack.com.gen.*;
	
	public class ArrowStruct
	{
		public var id:String;
		public var data:String;
		public var label:String;
		
		public var fromObj:NodeStruct;
		public var toObj:NodeStruct;
		
		public var graph:GraphStruct;
    	
    	public function ArrowStruct(	_id:String = null,
    									_label:String = "",
    									_data:String = null, 
    									_fromObj:NodeStruct = null, 
    									_toObj:NodeStruct = null,
    									_graph:GraphStruct = null)
		{
			id = _id;
			label = _label;
			data = _data;
			
			fromObj = _fromObj;
			toObj = _toObj;
			
			graph = _graph;
		}
	}
}