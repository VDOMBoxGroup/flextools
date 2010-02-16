package net.vdombox.ide.common.vo
{

	public class ServerActionVO
	{
		public function ServerActionVO( name : String, container : Object )
		{
			_name = name;
			_container = container;
		}

		private var _id : String;

		private var _name : String;

		public var script : String;

		public var language : String;

		private var _container : Object;

		public function get container() : Object
		{
			return _container;
		}

		public function get id() : Object
		{
			return _id;
		}

		public function get name() : Object
		{
			return _name;
		}

		public function setID( value : String ) : void
		{
			_id = value;
		}
		
		public function toXML() : XML
		{
			return <Action ID={ _id ? _id : "" } Name={ _name } Language={ language } >{script}</Action>;
		}
	}
}