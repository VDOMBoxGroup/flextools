package net.vdombox.components.xmldialogeditor.model.vo.components.base
{
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeEnumVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;
	import net.vdombox.components.xmldialogeditor.model.vo.properties.PropertyComposit;

	public class ComponentGroup extends ComponentAddition
	{
		protected var _sort : AttributeEnumVO;
		protected var _options : PropertyComposit;
		private var _layout : AttributeEnumVO;
		private var _title : AttributeStringVO;
		
		public function ComponentGroup(value:XML)
		{
			super(value);
			
			if ( value && value.@sort[0] )
				sort = new AttributeEnumVO("sort", value.@sort, ["unsorted", "sortById", "sortByText"] );
			else
				sort = new AttributeEnumVO("sort", "unsorted", ["unsorted", "sortById", "sortByText"] );
			
			if ( value && value.@layout[0] )
				layout = new AttributeEnumVO("layout", value.@layout, ["vertical", "horizontal"] );
			else
				layout = new AttributeEnumVO("layout", "vertical", ["vertical", "horizontal"] );
			
			if ( value && value.hasOwnProperty( "Properties" ) )
			{
				var propertyList : XMLList = value.Properties[0]..Property;
				
				for each ( var property : XML in propertyList )
				{
					var name : String = property.@name[0];
					
					switch(name)
					{	
						case "options":
						{
							options = new PropertyComposit( name, property, 1 );
							
							break;
						}
							
						case "title":
						{
							title = new AttributeStringVO( 'title', property.toString() );
							
							break;
						}
							
						default:
						{
							break;
						}
					}
				}
			}
			
			if ( !options )
				options = new PropertyComposit ( "options", null, 1 );
		}
		
		[Bindable]
		public function get options():PropertyComposit
		{
			return _options;
		}
		
		public function set options(value:PropertyComposit):void
		{
			_options = value;
		}
		
		public function get sort():AttributeEnumVO
		{
			return _sort;
		}
		
		public function set sort(value:AttributeEnumVO):void
		{
			_sort = value;
		}
		
		public function get layout():AttributeEnumVO
		{
			return _layout;
		}
		
		public function set layout(value:AttributeEnumVO):void
		{
			_layout = value;
		}
		
		[Bindable]
		public function get title():AttributeStringVO
		{
			return _title;
		}
		
		public function set title(value:AttributeStringVO):void
		{
			_title = value;
		}
	}
}