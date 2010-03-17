package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ActionParameterVO
	{
		public function ActionParameterVO( typeID : String, parameterDescription : XML )
		{
			_typeID = typeID;
			
			//TODO Гонимая локализация атрибутов "InterfaceName" и "Help"
			
			_name = parameterDescription.@ScriptName[ 0 ];
			_displayName = parameterDescription.@InterfaceName[ 0 ];
			_defaultValue = parameterDescription.@DefaultValue[ 0 ];
			_regularExpressionValidation = parameterDescription.@RegularExpressionValidation[ 0 ];
			_help = parameterDescription.@Help[ 0 ];
		}
		
		private const LANG_RE : RegExp = /#Lang\((\w+)\)/g;
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		private var _typeID : String;
		
		private var _name : String;
		private var _displayName : String;
		private var _defaultValue : String;
		private var _help : String;
		private var _regularExpressionValidation : String;
		
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
		
		public function get defaultValue() : String
		{
			return _defaultValue;
		}
		
		public function get help() : String
		{
			return getValue( _help );
		}
		
		public function get regularExpressionValidation() : String
		{
			return _regularExpressionValidation;
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