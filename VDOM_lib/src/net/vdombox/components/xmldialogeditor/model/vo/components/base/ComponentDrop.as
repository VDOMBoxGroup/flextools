package net.vdombox.components.xmldialogeditor.model.vo.components.base
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.OptionVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeEnumVO;
	import net.vdombox.components.xmldialogeditor.model.vo.properties.PropertyComposit;

	public class ComponentDrop extends ComponentAddition
	{
		protected var _sort : AttributeEnumVO;
		protected var _options : PropertyComposit;
		
		public function ComponentDrop(value:XML)
		{
			super(value);
			
			if ( value && value.@sort[0] )
				sort = new AttributeEnumVO("sort", value.@sort, ["unsorted", "sortById", "sortByText"] );
			else
				sort = new AttributeEnumVO("sort", "unsorted", ["unsorted", "sortById", "sortByText"] );
			
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
							options = new PropertyComposit( name, property );
							
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
				options = new PropertyComposit ( "options", null );
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
		
		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( sort );
			_attributes.addItem( options );
			
			return _attributes;
		}

	}
}