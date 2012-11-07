package net.vdombox.ide.common.model._vo
{
	import mx.resources.IResourceBundle;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceBundle;
	import mx.resources.ResourceManager;
	/**
	 *	The TypeVO is version of the Object`s description. 
	 */
	public class TypeVO
	{
		private const STANDART_CATEGORIES : Array = [ "usual", "standard", "form", "table", "database", "debug" ];
		
		private var attributesXML : XML;
		private var eventsXML : XML;
		private var actionsXML : XML;
		private var languages : XMLList;

		public function TypeVO( typeXML : XML )
		{
			languages = typeXML.Languages.*;

			var informationXML : XML = typeXML.Information[ 0 ];
			attributesXML = typeXML.Attributes[ 0 ];
			eventsXML = typeXML.E2vdom.Events[ 0 ];
			actionsXML = typeXML.E2vdom.Actions[ 0 ];

			var child : XML;
			var propertyName : String;
			var propertyValue : String;
			
			if( informationXML )
			{
				_typeID = informationXML.ID[ 0 ].toString();
				
				var informationXMLList : XMLList = informationXML.*;
				
				extractResources( informationXMLList, languages );
				
				for each ( child in informationXMLList )
				{
					propertyName = child.localName().toString().toLowerCase();
					propertyValue = child[ 0 ];
					
					informationPropertyObject[ propertyName ] = propertyValue;
				}
			}
			
			_attributeDescriptions = null;
			
			_events = null;
			
			_actions = null;
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var propertyRE : RegExp = /#Lang\((\w+)\)/;

		private var _typeID : String;

		private var _information : TypeInformationVO;
		
		private var _attributeDescriptions : Array;
		private var _events : Array;
		private var _actions : Array;

		private var informationPropertyObject : Object = {};
		
		public var includedInUserCategory : Boolean = false;

		public function get information() : TypeInformationVO
		{
			return _information;
		}

		public function get attributeDescriptions() : Array
		{
			if ( !_attributeDescriptions )
			{
				_attributeDescriptions = [];
				
				if( attributesXML )
				{
					var attributesXMLList : XMLList = attributesXML.*;
					
					extractResources( attributesXMLList, languages );
					
					var child : XML;
					
					for each ( child in attributesXML.* )
					{
						_attributeDescriptions.push( new AttributeDescriptionVO( _typeID, child ) );
					}
					
				}
			}
			
			return _attributeDescriptions.slice();
		}

		public function get actions() : Array
		{
			if ( !_actions )
			{
				_actions = [];
				
				if( actionsXML )
				{
					var actionsXMLList : XMLList = actionsXML..Action;
					var clientActionVO : ClientActionVO;
					
					extractResources( actionsXMLList, languages );
					
					var child : XML;
					
					for each ( child in actionsXMLList )
					{
						clientActionVO = new ClientActionVO( _typeID );
						clientActionVO.setProperties( child );
						
						_actions.push( clientActionVO );
					}
				}
			}
			
			return _actions.slice();
		}
		
		public function get events() : Array
		{
			if ( !_events )
			{
				_events = [];
				
				if( eventsXML )
				{
					var eventsXMLList : XMLList = eventsXML..Event;
					var eventVO : EventVO;
					
					extractResources( eventsXMLList, languages );
					
					var child : XML;
					
					for each ( child in eventsXMLList )
					{
						eventVO = new EventVO( _typeID );
						eventVO.setProperties( child );
						
						_events.push( eventVO );
					}
				}
			}
			
			return _events.slice();
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
				value = value.substring( 5, 41 );
			else
				value = "";

			return value;
		}

		public function get editorIconID() : String
		{
			var value : String = getInformationProperty( "editoricon" );

			if ( value.substr( 0, 4 ) == "#Res" )
				value = value.substring( 5, 41 );
			else
				value = "";

			return value;
		}

		public function get structureIconID() : String
		{
			var value : String = getInformationProperty( "structureicon" );

			if ( value.substr( 0, 4 ) == "#Res" )
				value = value.substring( 5, 41 );
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

		public function get container() : int
		{
			return int( getInformationProperty( "container" ) );
		}

		public function getEventVOByName ( eventName : String ) : EventVO
		{
			var result : EventVO;
			var eventVO : EventVO;
			
			for each ( eventVO in events )
			{
				if ( eventVO.name == eventName )
				{
					result = eventVO;
					break;
				}
			}
			
			return result;
		}
		
		private function getInformationProperty( valueName : String ) : String
		{
			var value : String = "";

			if ( !informationPropertyObject.hasOwnProperty( valueName ) )
				return value;

			var matchResult : Array = informationPropertyObject[ valueName ].match( propertyRE );

			if ( matchResult )
				value = resourceManager.getString( _typeID, matchResult[ 1 ] );
			else
				value = informationPropertyObject[ valueName ];

			return value;
		}

		private function extractResources( properties : XMLList, languages : XMLList ) : void
		{
			var prepareForResourceBundles : Object = {};
			var propertyName : String;
			var propertyValue : String;
			var propertyRE : RegExp = /#Lang\((\w+)\)/g;
			var matchResult : Array;

			var property : XML;

			for each ( property in properties )
			{
				propertyName = property.localName();
				propertyValue = property[ 0 ];

				matchResult = propertyValue.match( propertyRE );

				if ( !matchResult || matchResult.length == 0 )
					continue;

				var localeName : String;
				var sents : XMLList;
				var matchItem : String;
				var phraseID : String;


				for each( matchItem in matchResult )
				{
					phraseID = matchItem.substring( 6, matchItem.length - 1 );
					sents = languages.Sentence.( @ID == phraseID )

					for each ( var sent : XML in sents )
					{
						localeName = sent.parent().@Code;

						if ( !prepareForResourceBundles.hasOwnProperty( localeName ) )
							prepareForResourceBundles[ localeName ] = {};

						prepareForResourceBundles[ localeName ][ sent.@ID.toString() ] = sent[ 0 ].toString();
					}
				}
			}

			for ( var locale : String in prepareForResourceBundles )
			{
				var resourceName : String;
				var resourceBundle : IResourceBundle = resourceManager.getResourceBundle( locale, _typeID );

				if ( !resourceBundle )
					resourceBundle = new ResourceBundle( locale, _typeID );

				for ( resourceName in prepareForResourceBundles[ locale ] )
				{
					resourceBundle.content[ resourceName ] = prepareForResourceBundles[ locale ][ resourceName ];
				}

				resourceManager.addResourceBundle( resourceBundle );
			}
		}
	}
}