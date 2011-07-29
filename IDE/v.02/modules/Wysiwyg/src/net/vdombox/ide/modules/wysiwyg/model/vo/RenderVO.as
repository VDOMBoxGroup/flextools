package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	
	[Bindable]
	public class RenderVO
	{
		public function RenderVO( vdomObjectVO : IVDOMObjectVO )
		{
			super();
			
			_vdomObjectVO = vdomObjectVO;
		}
		
		public var staticFlag : Boolean;
		
		public var name : String;
		
		public var parent : RenderVO;
		public var children : Array;

		public var visible : Boolean;
		
		public var zindex : uint;
		public var hierarchy : uint;
		public var order : uint;
		
		public var attributes : Array;
		private var _content : XMLList;
		
		
		private var _vdomObjectVO : IVDOMObjectVO;
		
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
		
		
	}
}