package net.vdombox.ide.common.vo
{
	public class LevelObjectVO
	{
		public function LevelObjectVO( id : String )
		{
			_id = id;
		}
		
		public var level : uint;
		public var index : uint;
		
		private var _id : String;
		
		public function get id() : String
		{
			return _id;
		}
	}
}