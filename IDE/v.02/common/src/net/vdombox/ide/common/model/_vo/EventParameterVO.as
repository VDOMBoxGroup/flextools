package net.vdombox.ide.common.model._vo
{
	import mx.resources.ResourceManager;
	

	public class EventParameterVO
	{
		private var _typeID : String;
		private var _name : String;
		private var _order : String;
		private var _vbType : String;
		private var _help : String;
		
		private var propertyRE : RegExp = /#Lang\((\w+)\)/g;
		
		public function EventParameterVO( typeID : String )
		{
			_typeID = typeID;
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
		
		public function get help():String
		{				
			var matchResult : Array = String( _help ).match( propertyRE );
			var matchItem : String;
			var phraseID : String;
			
			var value : String = _help;
			
			if ( matchResult && matchResult.length > 0 )
			{
				for each ( matchItem in matchResult )
				{
					phraseID = matchItem.substring( 6, matchItem.length - 1 );
					value = value.replace( matchItem, ResourceManager.getInstance().getString( _typeID, phraseID ) );
				}
			}
			
			return value;
		}
		
		public function setProperties( propertiesXML : XML ) : void
		{
			_name = propertiesXML.@Name[ 0 ];
			_order = propertiesXML.@Order[ 0 ];
			_vbType = propertiesXML.@VbType[ 0 ];
			_help = propertiesXML.@Help[ 0 ];
		}
	}
}