package net.vdombox.ide.modules.dataBase.model.vo
{
	import mx.utils.UIDUtil;

	public class StructureVO
	{
		public var name : String;
		public var type : String;
		public var id : String;
		public var primary : Boolean;
		public var aincrement : Boolean;
		public var notnull : Boolean;
		public var unique : Boolean;
		public var defvalue : String;
		
		
		
		public function StructureVO( source : XML = null )
		{
			if ( source )
			{	
				name = source.@name.toString();
				type = source.@type.toString();
				id = source.@id.toString();
				primary = source.@primary.toString() == "true" ? true : false;
				aincrement = source.@autoincrement.toString() == "true" ? true : false;
				notnull = source.@notnull.toString() == "true" ? true : false;
				unique = source.@unique.toString() == "true" ? true : false;
				defvalue = source.@default.toString();
			}
			else
			{
				name = "NewColumn";
				type = "TEXT";
				id = UIDUtil.createUID().toLowerCase();
				primary = false;
				aincrement = false;
				notnull = false;
				unique = false;
				defvalue = "";
			}
		}
		
		public function copy() : StructureVO
		{
			var structureVO : StructureVO = new StructureVO();
			
			structureVO.name = name;
			structureVO.type = type;
			structureVO.id = id;
			structureVO.primary = primary;
			structureVO.aincrement = aincrement;
			structureVO.notnull = notnull;
			structureVO.unique = unique;
			structureVO.defvalue = defvalue;
			
			return structureVO;
		}
	}
}