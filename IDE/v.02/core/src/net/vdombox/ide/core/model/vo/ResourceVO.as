package net.vdombox.ide.core.model.vo
{
	import flash.utils.ByteArray;

	public class ResourceVO
	{
		public function ResourceVO( ownerID : String, resourceID : String )
		{
			_ownerID = ownerID;
			_resourceID = resourceID;
		}
		
		private var _ownerID : String;
		
		private var _resourceID : String;
		
		private var _data : ByteArray;
		
		private var _status : String;
		
		public function get ownerID () : String
		{
			return _ownerID;
		}
		
		public function get resourceID () : String
		{
			return _resourceID;
		}
		
		public function get status () : String
		{
			return _status;
		}
		
		public function get data () : ByteArray
		{
			return _data;
		}
		
		public function setStatus ( value : String ) : void
		{
			_status = value;
		}
		
		public function setData ( value : ByteArray ) : void
		{
			_data = value;
		}
	}
}