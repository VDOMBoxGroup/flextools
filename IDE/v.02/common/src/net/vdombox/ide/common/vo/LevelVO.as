package net.vdombox.ide.common.vo
{
	public class LevelVO
	{
		public function LevelVO( index : uint )
		{
			_index = index;
		}

		public var objects : Array;
		
		private var _index : uint;

		private function get index() : uint
		{
			return _index;
		}
		
		public function setDescription( description : XML ) : void
		{
			var sourceLevelObjects : XMLList = description.Object;
			objects = null;
			
			if ( sourceLevelObjects.length() == 0 )
				return;
			
			objects = [];
			var levelObjectVO : LevelObjectVO;
			
			for each ( var levelObjectXML : XML in sourceLevelObjects )
			{
				levelObjectVO = new LevelObjectVO( levelObjectXML.@ID );
				levelObjectVO.setDescription( levelObjectXML );
				
				objects.push( levelObjectVO );
			}
		}
	}
}