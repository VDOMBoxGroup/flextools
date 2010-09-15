package net.vdombox.ide.common.vo
{
	[Bindable]
	public class AttributeVO
	{
		public function AttributeVO( name : String, value : String = undefined )
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
			var result : XML;
			var xmlCharRegExp : RegExp = /[<>&"]+/;
			var value : String = this.value;
			
			if( value.search( xmlCharRegExp ) != -1 )
			{	
				value = value.replace(/\]\]>/g, "]]]]"+"><![CDATA[>" );
				value = "<Attribute Name=\""+ name +"\"><![CDATA[" + value + "]" + "]></Attribute>"
				result = new XML( value );
			}
			else
			{
				result =  <Attribute Name={_name}>{value}</Attribute>;
			}
				
			return result;
		}
		
		
	}
}