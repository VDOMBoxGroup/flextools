package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class EventParameterVO
	{
		public function EventParameterVO()
		{
		}

		private const LANG_RE : RegExp = /#Lang\((\w+)\)/g;

		private var _name : String;
		private var _order : String;
		private var _vbType : String;

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

		public function setProperties( propertiesXML : XML ) : void
		{
			_name = propertiesXML.@Name[ 0 ];
			_order = propertiesXML.@Order[ 0 ];
			_vbType = propertiesXML.@VbType[ 0 ];
		}
	}
}