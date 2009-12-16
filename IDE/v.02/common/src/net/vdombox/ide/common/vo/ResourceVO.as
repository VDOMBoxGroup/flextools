package net.vdombox.ide.common.vo
{
	import flash.utils.ByteArray;

	[Bindable]
	public class ResourceVO
	{
		public function ResourceVO()
		{
			_name = "";
			_type = "";
		}
		
		private var _ownerID : String;

		private var _resourceID : String;
		
		private var _type : String;
		
		private var _name : String;
		
		private var _data : ByteArray;
		
		private var _status : String;

		public function get ownerID() : String
		{
			return _ownerID;
		}

		public function set ownerID( value : String ) : void
		{
			_ownerID = value;
		}
		
		public function get resourceID() : String
		{
			return _resourceID;
		}
		
		public function set resourceID( value : String ) : void
		{
			_resourceID = value;
		}
		
		public function get name() : String
		{
			return _type;
		}
		
		public function set name( value : String ) : void
		{
			_type = value;
		}
		
		public function get type() : String
		{
			return _type;
		}
		
		public function set type( value : String ) : void
		{
			_type = value;
		}
		
		public function get status() : String
		{
			return _status;
		}

		public function set status( value : String ) : void
		{
			_status = value;
		}

		public function get data() : ByteArray
		{
			return _data;
		}

		public function set data( value : ByteArray ) : void
		{
			_data = value;
		}
	}
}