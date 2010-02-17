package net.vdombox.ide.common.vo
{
	[Bindable]
	public class AttributeVO
	{
		public function AttributeVO( name : String, value : String )
		{
			_name = name;
			this.value = _defaultValue = value;
		}
		
		private var _name : String;
		private var _defaultValue : String;
		
		public var value : String;
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get defaultValue() : String
		{
			return _defaultValue;
		}
	
		public function toXML() : XML
		{
			return <Attribute Name={_name}>{value}</Attribute>;
		}
		
		
	}
}