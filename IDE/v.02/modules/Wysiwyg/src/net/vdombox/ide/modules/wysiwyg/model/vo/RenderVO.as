package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import mx.collections.ArrayCollection;

	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;

	[Bindable]
	public class RenderVO
	{
		public function RenderVO( vdomObjectVO : IVDOMObjectVO )
		{
			super();

			_vdomObjectVO = vdomObjectVO;
		}

		public var staticFlag : Boolean;

		private var _name : String;

		private var _parent : RenderVO;

		private var _children : Array;

		public var visible : Boolean;

		public var zindex : int;

		public var hierarchy : int;

		public var order : int;

		public var attributes : Array;

		private var _content : XMLList;


		private var _vdomObjectVO : IVDOMObjectVO;

		public function get parent() : RenderVO
		{
			return _parent;
		}

		public function set parent( value : RenderVO ) : void
		{
			_parent = value;
		}

		public function get children() : Array
		{
			return _children;
		}

		public function set children( value : Array ) : void
		{
			_children = value;
		}

		public function get name() : String
		{
			return _name;
		}

		public function set name( value : String ) : void
		{
			_name = value;
		}

		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _vdomObjectVO;
		}

		public function getAttributeByName( name : String ) : AttributeVO
		{
			var result : AttributeVO;
			var attributeVO : AttributeVO;

			for each ( attributeVO in attributes )
			{
				if ( attributeVO.name == name )
				{
					result = attributeVO;
					break;
				}
			}

			return result;
		}


		public function get content() : XMLList
		{
			return _content;
		}

		public function set content( value : XMLList ) : void
		{
			_content = value;
		}

		public function get sortedChildren() : ArrayCollection
		{
			var childrenDataProvider : Array = new Array();

			for each ( var r : RenderVO in children )
			{
				childrenDataProvider.push( r );
			}

			var leng : int = childrenDataProvider.length;
			var temp : RenderVO;

			for ( var i : int = 0; i < leng; i++ )
			{
				for ( var j : int = i + 1; j < leng; j++ )
				{
					if ( childrenDataProvider[ i ].zindex === childrenDataProvider[ j ].zindex )
					{
						if ( childrenDataProvider[ i ].hierarchy === childrenDataProvider[ j ].hierarchy )
						{
							if ( childrenDataProvider[ i ].order > childrenDataProvider[ j ].order )
							{
								temp = childrenDataProvider[ i ];
								childrenDataProvider[ i ] = childrenDataProvider[ j ];
								childrenDataProvider[ j ] = temp;
							}
						}
						else if ( childrenDataProvider[ i ].hierarchy > childrenDataProvider[ j ].hierarchy )
						{
							temp = childrenDataProvider[ i ];
							childrenDataProvider[ i ] = childrenDataProvider[ j ];
							childrenDataProvider[ j ] = temp;
						}
					}
					else if ( childrenDataProvider[ i ].zindex > childrenDataProvider[ j ].zindex )
					{
						temp = childrenDataProvider[ i ];
						childrenDataProvider[ i ] = childrenDataProvider[ j ];
						childrenDataProvider[ j ] = temp;
					}
				}
			}

			//childrenDataProvider.sort( sortRender );

			/*
			   childrenDataProvider.sort = new Sort();

			   var zindexSort : SortField = new SortField( "zindex" );
			   zindexSort.numeric = true;

			   var hierarchySort : SortField = new SortField( "hierarchy" );
			   hierarchySort.numeric = true;

			   var orderSort : SortField = new SortField( "order" );
			   orderSort.numeric = true;

			   childrenDataProvider.sort.fields = [ /*zindexSort, hierarchySort, orderSort ];
			   childrenDataProvider.sort.compareFunction = sortRender;
			   childrenDataProvider.refresh();
			 */

			return new ArrayCollection( childrenDataProvider );

		}
	}
}
