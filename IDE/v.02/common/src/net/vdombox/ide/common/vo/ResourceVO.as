package net.vdombox.ide.common.vo
{
	import flash.utils.ByteArray;

	[Bindable]
	public class ResourceVO
	{
		public function ResourceVO( ownerID : String )
		{
			_ownerID = ownerID;
			;
		}

		private var _ownerID : String;


		private var _id : String;

		private var _useCount : int = -1;

		private var _name : String;

		private var _type : String;

		private var _path : String;

		private var _data : ByteArray;

		private var _status : String;

		public function get ownerID() : String
		{
			return _ownerID;
		}

		public function get id() : String
		{
			return _id;
		}

		public function get useCount() : int
		{
			return _useCount;
		}

		public function get name() : String
		{
			return _name;
		}

		public function set name( value : String ) : void
		{
			_name = value;
		}

		public function get type() : String
		{
			return _type;
		}

		public function get data() : ByteArray
		{
			return _data;
		}

		public function get size() : int
		{
			if ( !_data )
				return -1;

			_data.position = 0;

			return _data.bytesAvailable;
		}

		public function get path() : String
		{
			return _path;
		}

		public function get status() : String
		{
			return _status;
		}

		public function setType( value : String ) : void
		{
			_type = value.toLowerCase();
		}

		public function setData( value : ByteArray ) : void
		{
			_data = value;
		}

		public function setPath( value : String ) : void
		{
			_path = value;
		}

		public function setStatus( value : String ) : void
		{
			_status = value;
		}

		public function setXMLDescription( description : XML ) : void
		{
			if ( description.@id[ 0 ] )
				_id = description.@id;

			if ( description.@name[ 0 ] )
				name = description.@name;

			if ( description.@type[ 0 ] )
				_type = description.@type;

			if ( description.@usecount[ 0 ] )
				_useCount = description.@usecount;
		}
	}
}