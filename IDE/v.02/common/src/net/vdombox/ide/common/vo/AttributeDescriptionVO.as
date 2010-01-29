package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class AttributeDescriptionVO
	{
		public function AttributeDescriptionVO( typeID : String, attributeDescriptions : XML )
		{
			var propertyName : String;
			var propertyValue : String;

			_typeID = typeID;
			propertyObject = {};

			for each ( var property : XML in attributeDescriptions.* )
			{
				propertyName = property.localName();

				if ( propertyName === null )
					continue;

				propertyName = propertyName.toLowerCase();
				propertyValue = property[ 0 ];

				propertyObject[ propertyName ] = propertyValue;
				continue;
			}
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _typeID : String;

		private var propertyObject : Object;

		private var propertyRE : RegExp = /#Lang\((\w+)\)/;

		public function get typeID() : String
		{
			return typeID;
		}

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

			if ( !propertyObject.hasOwnProperty( valueName ) )
				return value;

			var matchResult : Array = String( propertyObject[ valueName ] ).match( propertyRE );

			if ( matchResult )
				value = resourceManager.getString( _typeID, matchResult[ 1 ] );
			else
				value = propertyObject[ valueName ];

			return value;
		}
	}
}