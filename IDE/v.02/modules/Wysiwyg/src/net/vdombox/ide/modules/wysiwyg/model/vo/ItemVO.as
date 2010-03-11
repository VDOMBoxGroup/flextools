package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	
	[Bindable]
	public class ItemVO
	{
		public function ItemVO( id : String )
		{
			super();
			
			_id = id;
		}
		
		public var name : String;
		
		public var pageVO : PageVO;
		public var typeVO : TypeVO;
		
		public var staticFlag : Boolean;
		
		public var parent : ItemVO;
		public var children : Array = [];

		public var visible : Boolean;
		
		public var zindex : uint;
		public var hierarchy : uint;
		public var order : uint;
		
		public var attributes : Array = [];
		public var content : XMLList;
		
		private var _id : String;
		
		public function get id() : String
		{
			return _id;
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
	}
}