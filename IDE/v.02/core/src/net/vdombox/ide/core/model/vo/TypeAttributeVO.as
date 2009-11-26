package net.vdombox.ide.core.model.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class TypeAttributeVO
	{
		public function TypeAttributeVO( typeName : String, typeAttribute : XML )
		{
			var propertyName : String;
			var propertyValue : String;
			
			_typeName = typeName;
			propertyObject = {};
			
			for each ( var property : XML in typeAttribute.* )
			{
				propertyName = property.localName().toString().toLowerCase();
				propertyValue = property[ 0 ];
				
				propertyObject[ propertyName ] = propertyValue;
				continue;
			}
		}
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		private var _typeName : String;
		
		private var propertyObject : Object;
		
		private var propertyRE : RegExp = /#Lang\((\w+)\)/;
		
		public function get name() : String
		{
			return getValue( "name" );
		}
		
		public function get displayName() : String
		{
			return getValue( "displayName" );
		}
		public function get defaultValue() : String
		{
			return getValue( "defaultValue" );
		}
		
		private function getValue( valueName : String ) : String
		{
			var value : String = "";
			valueName = valueName.toLowerCase();
			
			if( !propertyObject.hasOwnProperty( valueName ) )
				return value;
			
			var matchResult : Array = String( propertyObject[ valueName ] ).match( propertyRE );
			
			if( matchResult )
				value = resourceManager.getString( _typeName, matchResult[ 1 ] );
			else
				value = propertyObject[ valueName ];
			
			return value;
				
			
		}
	}
}