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

			_typeName = informationXML.Name[ 0 ].toString();


			var propertyName : String;
			var propertyValue : String;
			var propertyObject : String;

			extractResources( informationXML.*, languages );
			extractResources( attributesXML.Attribute.*, languages );

			_information = new TypeInformationVO( _typeName, informationXML );

			_attributes = [];

			for each ( var attribute : XML in attributesXML.* )
			{
				_attributes.push( new TypeAttributeVO( _typeName, attribute ) );
			}

			resourceManager.update();
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _typeName : String;

		private var _information : TypeInformationVO;

		private var _attributes : Array;

		public function get information() : Object
		{
			return _information;
		}

		public function get attributes() : Array
		{
			return _attributes.slice();
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
				var sents : XMLList = languages.Sentence.( @ID == matchResult[ 1 ])

				for each ( var sent : XML in sents )
				{
					localeName = sent.parent().@Code;

					if ( !prepareForResourceBundles.hasOwnProperty( localeName ))
						prepareForResourceBundles[ localeName ] = {};

					prepareForResourceBundles[ localeName ][ sent.@ID.toString()] = sent[ 0 ].toString();
				}
			}

			for ( var locale : String in prepareForResourceBundles )
			{
				var resourceName : String;
				var resourceBundle : IResourceBundle = resourceManager.getResourceBundle( locale, _typeName );

				if ( !resourceBundle )
					resourceBundle = new ResourceBundle( locale, _typeName );

				for ( resourceName in prepareForResourceBundles[ locale ])
				{
					resourceBundle.content[ resourceName ] = prepareForResourceBundles[ locale ][ resourceName ];
				}

				resourceManager.addResourceBundle( resourceBundle );
			}
		}
	}
}