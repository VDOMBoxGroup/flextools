package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceBundle;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager;

	public class TypeVO
	{
		public function TypeVO( typeXML : XML )
		{
			var languages : XMLList = typeXML.Languages.*;

			var informationXML : XML = typeXML.Information[ 0 ];
			var attributesXML : XML = typeXML.Attributes[ 0 ];

			_typeName = "type_" + informationXML.Name[ 0 ].toString();

			extractResources( informationXML.*, languages );
			extractResources( attributesXML.Attribute.*, languages );

			var propertyName : String;
			var propertyValue : String;

			for each ( var property : XML in informationXML.* )
			{
				propertyName = property.localName().toString().toLowerCase();
				propertyValue = property[ 0 ];

				informationPropertyObject[ propertyName ] = propertyValue;
			}

			for each ( var attribute : XML in attributesXML.* )
			{
				_attributes.push( new TypeAttributeVO( _typeName, attribute ) );
			}

			resourceManager.update();
		}

		private const STANDART_CATEGORIES : Array = [ "usual", "standard", "form", "table", "database",
													  "debug" ];

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var propertyRE : RegExp = /#Lang\((\w+)\)/;

		private var _typeName : String;

		private var _information : TypeInformationVO;

		private var _attributes : Array = [];

		private var informationPropertyObject : Object = {};

		public function get information() : TypeInformationVO
		{
			return _information;
		}

		public function get attributes() : Array
		{
			return _attributes.slice();
		}

		public function get id() : String
		{
			return getInformationProperty( "id" );
		}

		public function get name() : String
		{
			return getInformationProperty( "name" );
		}

		public function get displayName() : String
		{
			return getInformationProperty( "displayname" );
		}

		public function get description() : String
		{
			return getInformationProperty( "description" );
		}

		public function get className() : String
		{
			return getInformationProperty( "classname" );
		}

		/* this three properties are implementation of "iconID state" values.
		MD5 values return empty string*/
		
		public function get iconID() : String
		{
			var value : String = getInformationProperty( "icon" );

			if ( value.substr( 0, 4 ) == "#Res" )
				value = value.substring( 5, 36 );
			else
				value = "";

			return value;
		}

		public function get editorIconID() : String
		{
			var value : String = getInformationProperty( "editoricon" );
			
			if ( value.substr( 0, 4 ) == "#Res" )
				value = value.substring( 5, 36 );
			else
				value = "";
			
			return value;
		}
		
		public function get structureIconID() : String
		{
			var value : String = getInformationProperty( "structureicon" );
			
			if ( value.substr( 0, 4 ) == "#Res" )
				value = value.substring( 5, 36 );
			else
				value = "";
			
			return value;
		}

		public function get icon() : String
		{
			var value : String = getInformationProperty( "icon" );
			
			if ( value.substr( 0, 4 ) == "#Res" )
				value = "";
			
			return value;
		}
		
		public function get editorIcon() : String
		{
			var value : String = getInformationProperty( "editoricon" );
			
			if ( value.substr( 0, 4 ) == "#Res" )
				value = "";
			
			return value;
		}
		
		public function get structureIcon() : String
		{
			var value : String = getInformationProperty( "structureicon" );
			
			if ( value.substr( 0, 4 ) == "#Res" )
				value = "";
			
			return value;
		}
		
		public function get moveable() : String
		{
			return getInformationProperty( "moveable" );
		}

		public function get resizable() : String
		{
			return getInformationProperty( "resizable" );
		}

		public function get category() : String
		{
			var categoryName : String = getInformationProperty( "category" );

			var generalCategory : String = resourceManager.getString( "Types", categoryName.toLowerCase() );

			if ( generalCategory )
				categoryName = generalCategory;

			return categoryName;
		}

		public function get dynamic() : String
		{
			return getInformationProperty( "dynamic" );
		}

		public function get version() : String
		{
			return getInformationProperty( "version" );
		}

		public function get interfaceType() : String
		{
			return getInformationProperty( "interfacetype" );
		}

		public function get optimizationPriority() : String
		{
			return getInformationProperty( "optimizationpriority" );
		}

		public function get containers() : String
		{
			return getInformationProperty( "containers" );
		}

		public function get container() : String
		{
			return getInformationProperty( "container" );
		}

		private function getInformationProperty( valueName : String ) : String
		{
			var value : String = "";

			if ( !informationPropertyObject.hasOwnProperty( valueName ) )
				return value;

			var matchResult : Array = informationPropertyObject[ valueName ].match( propertyRE );

			if ( matchResult )
				value = resourceManager.getString( _typeName, matchResult[ 1 ] );
			else
				value = informationPropertyObject[ valueName ];

			return value;
		}

		private function extractResources( properties : XMLList, languages : XMLList ) : void
		{
			var prepareForResourceBundles : Object = {};
			var propertyName : String;
			var propertyValue : String;
			var propertyRE : RegExp = /#Lang\((\w+)\)/;
			var matchResult : Array;

			var property : XML;

			for each ( property in properties )
			{
				propertyName = property.localName();
				propertyValue = property[ 0 ];

				matchResult = propertyValue.match( propertyRE );

				if ( !matchResult )
					continue;

				var localeName : String;
				var sents : XMLList = languages.Sentence.( @ID == matchResult[ 1 ] )

				for each ( var sent : XML in sents )
				{
					localeName = sent.parent().@Code;

					if ( !prepareForResourceBundles.hasOwnProperty( localeName ) )
						prepareForResourceBundles[ localeName ] = {};

					prepareForResourceBundles[ localeName ][ sent.@ID.toString() ] = sent[ 0 ].toString();
				}
			}

			for ( var locale : String in prepareForResourceBundles )
			{
				var resourceName : String;
				var resourceBundle : IResourceBundle = resourceManager.getResourceBundle( locale, _typeName );

				if ( !resourceBundle )
					resourceBundle = new ResourceBundle( locale, _typeName );

				for ( resourceName in prepareForResourceBundles[ locale ] )
				{
					resourceBundle.content[ resourceName ] = prepareForResourceBundles[ locale ][ resourceName ];
				}

				resourceManager.addResourceBundle( resourceBundle );
			}
		}
	}
}