package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class EventParameterVO
	{
		public function EventParameterVO( typeID : String, parameterDescription : XML )
		{
			_typeID = typeID;

			_name = parameterDescription.@Name[ 0 ];
			_help = parameterDescription.@Help[ 0 ];
			_order = parameterDescription.@Order[ 0 ];
			_vbType = parameterDescription.@VbType[ 0 ];
		}

		private const LANG_RE : RegExp = /#Lang\((\w+)\)/g;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var _typeID : String;

		private var _name : String;
		private var _help : String;
		private var _order : String;
		private var _vbType : String;

		public function get typeID() : String
		{
			return _typeID;
		}

		public function get name() : String
		{
			return _name;
		}

		public function get order() : String
		{
			return _order;
		}

		public function get vbType() : String
		{
			return _vbType;
		}

		public function get help() : String
		{
			return getValue( _help );
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