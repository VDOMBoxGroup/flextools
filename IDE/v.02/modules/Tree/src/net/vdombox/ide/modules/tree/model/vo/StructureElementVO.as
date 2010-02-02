package net.vdombox.ide.modules.tree.model.vo
{
	public class StructureElementVO
	{
		public function StructureElementVO( id : String )
		{
			_id = id;
			
			top = 0;
			left = 0;
			
			state = false;
		}
		
		public var top : int;
		
		public var left : int;
		
		public var width : int;
		
		public var height : int;
		
		public var state : Boolean;
		
		private var _id : String;
		
		public function get id () : String
		{
			return _id;
		}
	}
}