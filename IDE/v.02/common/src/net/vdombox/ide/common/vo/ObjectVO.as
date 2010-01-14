package net.vdombox.ide.common.vo
{
	public class ObjectVO
	{
		public function ObjectVO( id : String, applicationID : String, pageID : String, typeID : String )
		{
			_id = id;
			_typeID = typeID;
		}

		private var _id : String;

		private var _typeID : String;

		private var _name : String;

		public function get id() : String
		{
			return _id;
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