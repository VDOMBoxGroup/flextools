package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.TypeVO;
	
	[Bindable]
	public class ItemVO
	{
		public var id : String;
		public var name : String;
		public var typeVO : TypeVO;
		
		public var staticFlag : String;
		
		public var parent : ItemVO;
		public var children : Array = [];

		public var visible : Boolean;
		
		public var zindex : uint;
		public var hierarchy : uint;
		public var order : uint;
		
		public var attributes : Array = [];
		public var content : XMLList;
		
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