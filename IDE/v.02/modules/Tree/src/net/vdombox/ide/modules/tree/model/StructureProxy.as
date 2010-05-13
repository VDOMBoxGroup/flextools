package net.vdombox.ide.modules.tree.model
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.common.vo.LevelObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;

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

		private var rawStructure : Array;

//		-----------------------------
		private var _treeLevels : Array;

		private var _treeElements : Array;

		private var treeElementsObject : Object;

		private var _linkages : Array;

		private var treeElementsChanged : Boolean;

		private var rawStructureChanged : Boolean;

		public function get treeLevels() : Array
		{
			return _treeLevels;
		}

		public function get treeElements() : Array
		{
			return _treeElements;
		}

		public function set treeElements( value : Array ) : void
		{
			_treeElements = value;
		}

		public function get linkages() : Array
		{
			return _linkages;
		}

		public function set linkages( value : Array ) : void
		{
			_linkages = value;
		}

		override public function onRegister() : void
		{
			treeElementsObject = {};
			rawStructure = [];

			_treeElements = [];
			_treeLevels = [];
			_linkages = [];

			for each ( var properties : Object in LEVELS_PROERTIES )
			{
				var treeLevelVO : TreeLevelVO = new TreeLevelVO();

				treeLevelVO.color = properties.color;
				treeLevelVO.level = properties.level;
				treeLevelVO.label = resourceManager.getString( "Tree_General", "level_" + properties.level );

				_treeLevels.push( treeLevelVO );
			}
		}

		override public function onRemove() : void
		{
			treeElementsObject = null;
			rawStructure = null;

			_treeElements = null;
			_treeLevels = null;
			_linkages = null;
		}

		public function setPages( pages : Array ) : void
		{
			var treeElementVO : TreeElementVO;
			var pageVO : PageVO;

			for each ( pageVO in pages )
			{
				if ( treeElementsObject.hasOwnProperty( pageVO.id ) )
					continue;

				treeElementVO = new TreeElementVO( pageVO );

				treeElementsObject[ treeElementVO.id ] = treeElementVO;
				_treeElements.push( treeElementVO );

				treeElementsChanged = true;
				rawStructureChanged = true;

			}

			if ( treeElementsChanged )
			{
				commitProperties();
				sendNotification( ApplicationFacade.TREE_ELEMENTS_CHANGED, treeElements );
			}
		}

		public function setRawSructure( rawStructure : Array ) : void
		{
			this.rawStructure = rawStructure;

			rawStructureChanged = true;

			commitProperties();
		}

		public function getRawSructure() : Array
		{
			var treeElementVO : TreeElementVO;
			var linkageVO : LinkageVO;

			var structureObjectVO : StructureObjectVO;
			var levelObjectVO : LevelObjectVO;

			var levels : Array;
			var index : uint;

			var rawStructure : Array = [];
			var tempLinkage : Array = _linkages.slice();

			for each ( treeElementVO in treeElements )
			{
				structureObjectVO = new StructureObjectVO( treeElementVO.id );
				structureObjectVO.top = treeElementVO.top;
				structureObjectVO.left = treeElementVO.left;
				structureObjectVO.resourceID = treeElementVO.resourceVO ? treeElementVO.resourceVO.id : "";
				structureObjectVO.state = treeElementVO.state;

				levels = [];
				index = 0;

				for ( var i : uint = 0; i < tempLinkage.length; i++ )
				{
					linkageVO = tempLinkage[ i ];

					if ( linkageVO.source == treeElementVO )
					{
						levelObjectVO = new LevelObjectVO( linkageVO.target.id );
						levelObjectVO.level = linkageVO.level.level;
						levelObjectVO.index = index;
						index++;

						levels.push( levelObjectVO );

						tempLinkage.splice( i, 1 );
						i--;
					}
				}

				structureObjectVO.levels = levels;
				rawStructure.push( structureObjectVO );
			}

			return rawStructure;
		}

		public function getTreeElementByVO( pageVO : PageVO ) : TreeElementVO
		{
			return treeElementsObject[ pageVO.id ];
		}

		public function cretaeTreeElementByVO( pageVO : PageVO ) : void
		{
			var treeElementVO : TreeElementVO = treeElementsObject[ pageVO.id ];

			if ( treeElementVO )
				return;

			treeElementVO = new TreeElementVO( pageVO );

			treeElementsObject[ treeElementVO.id ] = treeElementVO;
			treeElements.push( treeElementVO );

			treeElementsChanged = true;

			commitProperties();

			sendNotification( ApplicationFacade.TREE_ELEMENTS_CHANGED, treeElements );
		}

		public function deleteTreeElementByVO( pageVO : PageVO ) : void
		{
			var treeElementVO : TreeElementVO = treeElementsObject[ pageVO.id ];

			if ( !treeElementVO )
				return;

			var i : uint;

			for ( i = 0; i < treeElements.length; i++ )
			{
				if ( treeElements[ i ] != treeElementVO )
					continue;

				deleteTreeElementLinkages( treeElementVO );

				treeElements.splice( i, 1 );

				sendNotification( ApplicationFacade.TREE_ELEMENTS_CHANGED, treeElements );

				break;
			}
		}

		public function createLinkage( value : LinkageVO ) : void
		{
			_linkages.push( value );

			sendNotification( ApplicationFacade.LINKAGES_CHANGED, linkages );
		}

		public function deleteLinkage( value : LinkageVO ) : void
		{
			if ( !value )
				return;

			var currentLinkageVO : LinkageVO;
			var thisIndex : Boolean = false;
			for ( var i : int = 0; i < _linkages.length; i++ )
			{
				currentLinkageVO = _linkages[ i ] as LinkageVO;

				try
				{
					if ( currentLinkageVO === value ||
						( currentLinkageVO.source.id == value.source.id && currentLinkageVO.target.id == value.target.id &&
						currentLinkageVO.level.level == value.level.level ) )
					{
						thisIndex = true;
					}
				}
				catch ( error : Error )
				{
				}

				if ( thisIndex )
				{
					_linkages.splice( i, 1 );
					break;
				}

			}

			sendNotification( ApplicationFacade.LINKAGES_CHANGED, linkages );
		}

		public function cleanup() : void
		{
			treeElementsObject = {};
			rawStructure = [];

			_treeElements = [];
			_treeLevels = [];
			_linkages = [];

			treeElementsChanged = false;
			rawStructureChanged = false;
		}

		private function commitProperties() : void
		{
			if ( treeElementsChanged )
			{
				treeElementsChanged = false;

				updateTreeElementsProperties();
			}

			if ( rawStructureChanged )
			{
				rawStructureChanged = false;

				createLinkages();
				updateTreeElementsProperties();
			}
		}

		private function updateTreeElementsProperties() : void
		{
			var treeElementVO : TreeElementVO;
			var rawStructureObject : StructureObjectVO;

			for each ( treeElementVO in _treeElements )
			{
				rawStructureObject = getStructureObjectByID( treeElementVO.id );

				if ( rawStructureObject )
				{
					treeElementVO.left = rawStructureObject.left;
					treeElementVO.top = rawStructureObject.top;
					treeElementVO.state = rawStructureObject.state;

					if ( treeElementVO.resourceVO && treeElementVO.resourceVO.id != rawStructureObject.resourceID )
					{
						treeElementVO.resourceVO = new ResourceVO( treeElementVO.pageVO.applicationVO.id )
						treeElementVO.resourceVO.setID( rawStructureObject.resourceID );
					}
				}
			}
		}

		private function createLinkages() : void
		{
			var linkageVO : LinkageVO;

			var source : TreeElementVO;
			var target : TreeElementVO;
			var level : TreeLevelVO;
			var index : uint;

			var treeElementVO : TreeElementVO;

			var rawStructureObject : StructureObjectVO;

			var levelObjectVO : LevelObjectVO;

			var isLinkagesChanged : Boolean = false;
			var resourceVO : ResourceVO;

			_linkages = [];

			for each ( treeElementVO in treeElements )
			{
				rawStructureObject = getStructureObjectByID( treeElementVO.id );

				if ( !rawStructureObject )
					continue;

				if ( ( !treeElementVO.resourceVO && rawStructureObject.resourceID ) ||
					( treeElementVO.resourceVO && treeElementVO.resourceVO.id != rawStructureObject.resourceID ) )
				{
					resourceVO = new ResourceVO( treeElementVO.pageVO.applicationVO.id );
					resourceVO.setID( rawStructureObject.resourceID );

					treeElementVO.resourceVO = resourceVO;
				}
				else if ( treeElementVO.resourceVO && !rawStructureObject.resourceID )
				{
					treeElementVO.resourceVO = null;
				}

				for each ( levelObjectVO in rawStructureObject.levels )
				{
					target = treeElementsObject[ levelObjectVO.id ];

					level = getTreeLevelByNumber( levelObjectVO.level );
					index = levelObjectVO.index;

					if ( !target || !level )
						continue;

					linkageVO = new LinkageVO();

					linkageVO.source = treeElementVO;
					linkageVO.target = target;
					linkageVO.level = level;
					linkageVO.index = index;

					_linkages.push( linkageVO );

					isLinkagesChanged = true;
				}
			}

			if ( isLinkagesChanged )
				sendNotification( ApplicationFacade.LINKAGES_CHANGED, linkages );
		}

		private function deleteTreeElementLinkages( treeElementVO : TreeElementVO ) : void
		{
			var linkageVO : LinkageVO;

			var isLinkagesChanged : Boolean;

			var i : uint;

			for ( i = 0; i < _linkages.length; i++ )
			{
				linkageVO = _linkages[ i ];

				if ( linkageVO.source != treeElementVO && linkageVO.target != treeElementVO )
					continue;

				_linkages.splice( i, 1 );
				i--;
				isLinkagesChanged = true;
			}

			if ( isLinkagesChanged )
				sendNotification( ApplicationFacade.LINKAGES_CHANGED, linkages );
		}

		private function getStructureObjectByID( id : String ) : StructureObjectVO
		{
			var result : StructureObjectVO;
			var structureObjectVO : StructureObjectVO;

			for each ( structureObjectVO in rawStructure )
			{
				if ( structureObjectVO.id == id )
				{
					result = structureObjectVO;
					break;
				}
			}

			return result;
		}

		private function getTreeLevelByNumber( number : uint ) : TreeLevelVO
		{
			var result : TreeLevelVO;

			for each ( var treeLevelVO : TreeLevelVO in _treeLevels )
			{
				if ( treeLevelVO.level == number )
				{
					result = treeLevelVO;
					break;
				}
			}

			return result;
		}

		private function hasLinkage( source : TreeElementVO, target : TreeElementVO, levelNumber : uint ) : Boolean
		{
			var result : Boolean = false;
			var linkageVO : LinkageVO;

			for each ( linkageVO in _linkages )
			{
				if ( linkageVO.source == source && linkageVO.target == target && linkageVO.level.level == levelNumber )
				{
					result = true;
					break;
				}
			}

			return result;
		}
	}
}