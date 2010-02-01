package net.vdombox.ide.modules.tree.model
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.modules.tree.model.vo.StructureLevelVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class StructureLevelsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "StructureProxy";

		public function StructureLevelsProxy()
		{
			super( NAME );
		}

		private const LEVELS_PROERTIES : Array = [ { color: 0xfcd700, level: 0 }, { color: 0x7ddd00, level: 1 }, { color: 0xdd00c0, level: 2 },
												   { color: 0x00ddc6, level: 3 }, { color: 0xdd0044, level: 4 }, { color: 0xb100dd, level: 5 },
												   { color: 0x81C9FF, level: 6 }, { color: 0x082478, level: 7 } ];

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _structureLevels : Array;

		public function get structureLevels() : Array
		{
			return _structureLevels;
		}

		override public function onRegister() : void
		{
			_structureLevels = [];

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
			_structureLevels = null;
		}
	}
}