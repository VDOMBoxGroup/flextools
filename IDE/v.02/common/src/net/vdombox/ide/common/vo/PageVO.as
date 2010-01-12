package net.vdombox.ide.common.vo
{
	[Bindable]
	public class PageVO
	{
		public function PageVO( id : String, applicationID : String, typeID : String )
		{
			_id = id;
			_applicationID = applicationID;
			_typeID = typeID;
		}
		
		private var _id : String;
		private var _applicationID : String;
		private var _typeID : String;
		private var _name : String;
		
		public function get id() : String
		{
			return _id;
		}
		
		public function get applicationID() : String
		{
			return _applicationID;
		}
		
		public function get typeID() : String
		{
			return _typeID;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function set name( value : String ) : void
		{
			
		}
		
		public function setXMLDescription( description : XML ) : void
		{
			_name = description.@Name[ 0 ];
			name = _name;
		}
	}
}