package net.vdombox.ide.common.model._vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	/**
	 * The AttributeDescriptionVO is Visual Object of VDOM Application.
	 * AttributeDescription is contained in VDOM Application. 
	 */
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

		private var propertyRE : RegExp = /#Lang\((\w+)\)/g;

		public function get typeID() : String
		{
			return _typeID;
		}

		public function get name() : String
		{
			return getValue( "name" );
		}

		public function get displayName() : String
		{
			return getValue( "displayname" );
		}

		public function get defaultValue() : String
		{
			return getValue( "defaultvalue" );
		}

		public function get colorGroup() : uint
		{
			return uint( getValue( "colorgroup" ) );
		}

		public function get codeInterface() : String
		{
			return getValue( "codeinterface" );
		}

		public function get interfaceType() : uint
		{
			return uint( getValue( "interfacetype" ) );
		}

		public function get help() : String
		{
			return getValue( "help" );
		}

		public function get visible() : Boolean
		{
			return getValue( "visible" ) == "1" ? true : false;
		}

		public function get errorValidationMessage() : String
		{
			return getValue( "errorvalidationmessage" );
		}

		public function get regularExpressionValidation() : String
		{
			return getValue( "regularexpressionvalidation" );
		}

		private function getValue( valueName : String ) : String
		{
			var value : String = "";
			valueName = valueName.toLowerCase();

			if ( !propertyObject.hasOwnProperty( valueName ) )
				return value;

			var matchResult : Array = String( propertyObject[ valueName ] ).match( propertyRE );
			var matchItem : String;
			var phraseID : String;

			value = propertyObject[ valueName ];

			if ( matchResult && matchResult.length > 0 )
			{
				for each ( matchItem in matchResult )
				{
					phraseID = matchItem.substring( 6, matchItem.length - 1 );
					value = value.replace( matchItem, resourceManager.getString( _typeID, phraseID ) );
				}
			}

			return value;
		}
	}
}