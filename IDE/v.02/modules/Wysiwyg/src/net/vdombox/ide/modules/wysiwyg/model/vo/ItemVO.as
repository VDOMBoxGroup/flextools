package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.common.vo.AttributeVO;
	
	[Bindable]
	public class ItemVO
	{
		public var id : String;
		public var type : String;
		
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
		
		public function setXMLDescription( description : XML ) : void
		{
			id = description.@id;
			type = description.name();
			
			visible = description.@visible == 1 ? true : false;
			
			zindex = description.@zindex;
			hierarchy = description.@hierarchy;
			order = description.@order;
			
			delete description.@id;
			delete description.@zindex;
			delete description.@hierarchy;
			delete description.@order;
			delete description.@visible;

			children = [];
			attributes = [];
			content = new XMLList();
			
			var childItemVO : ItemVO;
			var attributeVO : AttributeVO;
			var child : XML;
			var attribute : XML;
			
			for each ( attribute in description.@* )
			{
				attributeVO = new AttributeVO( attribute.name(), attribute[ 0 ] );
				attributes.push( attributeVO );
			}

			
			for each ( child in description.* )
			{
				var childName : String = child.name();

				if( childName == "container" || childName == "table" || childName == "row" || childName == "cell" )
				{
					childItemVO = new ItemVO();
					childItemVO.setXMLDescription( child );
					childItemVO.parent = this;
					
					children.push( childItemVO );
				}
				else
				{
					content += child.copy();
				}
			}
		}
	}
}