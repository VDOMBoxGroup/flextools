package net.vdombox.ide.common.vo
{
	public class StructureObjectVO
	{
		public function StructureObjectVO( id : String )
		{
			_id = id;
		}
		
		public var top : int = 0;
		
		public var left : int = 0;
		
		public var state : Boolean = false;
		
		public var levels : Array = [];
		
		private var _id : String;
		
		public function get id() : String
		{
			return _id;
		}
		
		public function setDescription( description : XML ) : void
		{
			levels = [];
			
			left = description.@left;
			top = description.@top;
			
			if ( description.@state == "true" )
				state = true;
			else
				state = false;
			
			var sourceLevels : XMLList = description.Level;
			
			if( sourceLevels.length() == 0 )
				return;
			
			var levelObjects : XMLList = sourceLevels.Object;
			
			var levelObjectVO : LevelObjectVO;
			var level : int;
			
			for each( var levelObjectXML : XML in levelObjects )
			{
				level = levelObjectXML.parent().@Index;
				
				levelObjectVO = new LevelObjectVO( levelObjectXML.@ID );
				
				levelObjectVO.level = level;
				levelObjectVO.index = levelObjectXML.@Index;
				
				
				levels.push( levelObjectVO );
			}
		}
	}
}