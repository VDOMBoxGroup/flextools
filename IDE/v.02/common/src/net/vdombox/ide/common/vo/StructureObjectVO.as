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

		public var resourceID : String;

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

			resourceID = description.@ResourceID;

			var sourceLevels : XMLList = description.Level;

			if ( sourceLevels.length() == 0 )
				return;

			var levelObjects : XMLList = sourceLevels.Object;

			var levelObjectVO : LevelObjectVO;
			var level : int;

			for each ( var levelObjectXML : XML in levelObjects )
			{
				level = levelObjectXML.parent().@Index;

				levelObjectVO = new LevelObjectVO( levelObjectXML.@ID );

				levelObjectVO.level = level;
				levelObjectVO.index = levelObjectXML.@Index;


				levels.push( levelObjectVO );
			}
		}

		public function toXML() : XML
		{
			var objectXML : XML =
				<Object ID={_id} top={top} left={left} ResourceID={resourceID} state={state}/>
				;
			var levelsXMLArray : Array = [];
			var levelObjectVO : LevelObjectVO;
			var levelXML : XML;
			var levelNumber : uint;

			for each ( levelObjectVO in levels )
			{
				levelNumber = levelObjectVO.level;

				if ( !levelsXMLArray[ levelNumber ] )
					levelsXMLArray[ levelNumber ] =
						<Level Index={levelNumber}/>
						;

				levelsXMLArray[ levelNumber ].appendChild( levelObjectVO.toXML() );
			}

			for each ( levelXML in levelsXMLArray )
			{
				objectXML.appendChild( levelXML );
			}

			return objectXML;
		}
	}
}