package net.vdombox.ide.modules.tree.model
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.common.vo.LevelObjectVO;
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.model.vo.StructureLevelVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class StructureProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "StructureProxy";

		public function StructureProxy()
		{
			super( NAME );
		}

		private const LEVELS_PROERTIES : Array = [ { color: 0xfcd700, level: 0 }, { color: 0x7ddd00,
													   level: 1 }, { color: 0xdd00c0, level: 2 }, { color: 0x00ddc6,
													   level: 3 }, { color: 0xdd0044, level: 4 }, { color: 0xb100dd,
													   level: 5 }, { color: 0x81C9FF, level: 6 }, { color: 0x082478,
													   level: 7 } ];

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _structureElements : Array;

		private var _structureLevels : Array;
		private var _linkages : Array;

		public function get structureLevels() : Array
		{
			return _structureLevels;
		}

		public function get structureElements() : Array
		{
			return _structureElements;
		}
		
		public function get linkages() : Array
		{
			return _linkages;
		}

		public function setSructure( rawStructure : Array ) : void
		{
			generateStructureElements( rawStructure );
			generateLinkages( rawStructure );
		}

		override public function onRegister() : void
		{
			_structureElements = [];
			_structureLevels = [];
			_linkages = [];

			for each ( var properties : Object in LEVELS_PROERTIES )
			{
				var structureLevelVO : StructureLevelVO = new StructureLevelVO();

				structureLevelVO.color = properties.color;
				structureLevelVO.level = properties.level;
				structureLevelVO.label = resourceManager.getString( "Tree_General", "level_" + properties.level );

				_structureLevels.push( structureLevelVO );
			}
		}

		override public function onRemove() : void
		{
			_structureElements = null;
			_structureLevels = null;
			_linkages = null;
		}

		private function generateStructureElements( value : Array ) : void
		{
			var structureElementVO : StructureElementVO;

			for each ( var rawStructureObject : StructureObjectVO in value )
			{
				structureElementVO = new StructureElementVO( rawStructureObject.id );

				structureElementVO.left = rawStructureObject.left;
				structureElementVO.top = rawStructureObject.top;
				structureElementVO.state = rawStructureObject.state;

				_structureElements.push( structureElementVO );
			}
		}

		private function generateLinkages( value : Array ) : void
		{
			var linkageVO : LinkageVO;

			var source : StructureElementVO;
			var target : StructureElementVO;
			var level : StructureLevelVO;
			var index : uint;

			for each ( var rawStructureObject : StructureObjectVO in value )
			{
				source = getStructureElementByID( rawStructureObject.id );

				for each ( var levelObjectVO : LevelObjectVO in rawStructureObject.levels )
				{
					target = getStructureElementByID( levelObjectVO.id );
					level = getStructureLevelByNumber( levelObjectVO.level );
					index = levelObjectVO.index;

					if ( !source || !target || !level )
						continue;

					linkageVO = new LinkageVO();

					linkageVO.target = target;
					linkageVO.source = source;
					linkageVO.level = level;
					linkageVO.index = index;
					
					_linkages.push( linkageVO );
				}
			}
		}

		private function getStructureElementByID( id : String ) : StructureElementVO
		{
			var result : StructureElementVO;

			for each ( var structureElementVO : StructureElementVO in _structureElements )
			{
				if ( structureElementVO.id == id )
				{
					result = structureElementVO;
					break;
				}
			}

			return result;
		}

		private function getStructureLevelByNumber( number : uint ) : StructureLevelVO
		{
			var result : StructureLevelVO;

			for each ( var structureLevelVO : StructureLevelVO in _structureLevels )
			{
				if ( structureLevelVO.level == number )
				{
					result = structureLevelVO;
					break;
				}
			}

			return result;
		}
	}
}