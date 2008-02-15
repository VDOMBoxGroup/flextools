package PowerPack.com.gen
{
	import PowerPack.com.gen.*;
	
	public class GraphStruct
	{
		public var id:String;
		public var name:String;
		public var bInitial:Boolean;
		
		public var initNode:NodeStruct;
		
		[ArrayElementType("NodeStruct")]
		public var nodes:Array;
		
		[ArrayElementType("ArrowStruct")]
		public var arrows:Array;
		
    	public function GraphStruct(	_id:String = null,
    									_name:String = null,
    									_bInitial:Boolean = false,
    									_initNode:NodeStruct = null)
		{
			id = _id;
			name = _name;
			bInitial = _bInitial;
			initNode = _initNode;
			
			nodes = new Array();
			arrows = new Array();
		}				
	}
}