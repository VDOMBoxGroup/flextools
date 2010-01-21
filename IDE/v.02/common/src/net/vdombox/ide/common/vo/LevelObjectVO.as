package net.vdombox.ide.common.vo
{
	public class LevelObjectVO
	{
		public function LevelObjectVO( id : String )
		{
			_id = id;
		}
		
		public var index : uint;
		
		private var _id : String;
		
		public function setDescription( description : XML ) : void
		{
			index = description.@Index;
		}
	}
}