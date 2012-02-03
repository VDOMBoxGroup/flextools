package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	
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
		
		public var zindex : uint;
		public var hierarchy : uint;
		public var order : uint;
		
		public var attributes : Array;
		private var _content : XMLList;
		
		
		private var _vdomObjectVO : IVDOMObjectVO;
		
		public function get parent():RenderVO
		{
			return _parent;
		}

		public function set parent(value:RenderVO):void
		{
			_parent = value;
		}

		public function get children():Array
		{
			return _children;
		}

		public function set children(value:Array):void
		{
			_children = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
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
			
			for each( attributeVO in attributes )
			{
				if( attributeVO.name == name )
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
		
		public function set content( value : XMLList) : void
		{
			 _content = value;
		}
		
		public function get sortedChildren(): ArrayCollection
		{
			
			var childrenDataProvider : ArrayCollection = new ArrayCollection( children );
			
			childrenDataProvider.sort = new Sort();
			childrenDataProvider.sort.fields = [ new SortField( "zindex" ), new SortField( "hierarchy" ), new SortField( "order" ) ];
			childrenDataProvider.refresh();
			
			return childrenDataProvider;
			 
		}
		
		
		
	}
}