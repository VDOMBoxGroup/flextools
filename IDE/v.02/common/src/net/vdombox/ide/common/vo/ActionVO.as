package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ActionVO
	{
		public function ActionVO( typeID : String, actionDescription : XML )
		{
			_typeID = typeID;
			
			_name = actionDescription.@MethodName[ 0 ];
			_displayName = actionDescription.@InterfaceName[ 0 ];
			_help = actionDescription.@Description[ 0 ];
			
			var parametersXML : XML = actionDescription.Parameters[ 0 ];
			var parameterXML : XML;
			
			if ( parametersXML )
			{
				for each ( parameterXML in parametersXML.* )
				{
					_parameters.push( new ActionParameterVO( _typeID, parameterXML ) );
				}
			}
		}
		
		private const LANG_RE : RegExp = /#Lang\((\w+)\)/g;
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		private var _typeID : String;
		
		private var _name : String;
		private var _displayName : String;
		private var _help : String;
		
		private var _parameters : Array = [];
		
		public function get typeID() : String
		{
			return _typeID;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get displayName() : String
		{
			return getValue( _displayName );
		}
		
		public function get help() : String
		{
			return getValue( _help );
		}
		
		public function get parameters() : Array
		{
			return _parameters;
		}
		
		private function getValue( value : String ) : String
		{
			var result : String = value ? value : "";
			
			var matchResult : Array = result.match( LANG_RE );
			
			var matchItem : String;
			var phraseID : String;
			
			if ( matchResult && matchResult.length > 0 )
			{
				for each ( matchItem in matchResult )
				{
					phraseID = matchItem.substring( 6, matchItem.length - 1 );
					result = value.replace( matchItem, resourceManager.getString( _typeID, phraseID ) );
				}
			}
			
			return result;
		}
	}
}