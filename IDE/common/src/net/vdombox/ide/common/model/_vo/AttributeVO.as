package net.vdombox.ide.common.model._vo
{

	[Bindable]
	public class AttributeVO
	{
		public function AttributeVO( name : String, value : String = "" )
		{
			_name = name;
			_value = _defaultValue = value;
		}

		private var _name : String;

		private var _defaultValue : String;

		private var _value : String = "";
		
		private var _index : int = -1;
		
		private var _itemRenderer : Object;

		public function get value() : String
		{
			return _value;
		}

		public function set value( value : String ) : void
		{
			_value = value;
		}

		public function get name() : String
		{
			return _name;
		}

		public function get defaultValue() : String
		{
			return _defaultValue;
		}
		
		public function set defaultValue( value : String ) : void
		{
			_defaultValue = value;
		}
		
		public function get index():int
		{
			return _index;
		}
		
		public function set index(value:int):void
		{
			_index = value;
		}

		public function toXML() : XML
		{
			var result : XML;
			var xmlCharRegExp : RegExp = /[<>&"]+/;
			var value : String = this.value;

			if ( value.search( xmlCharRegExp ) != -1 )
			{
				value = value.replace( /\]\]>/g, "]]]]" + "><![CDATA[>" );
				value = "<Attribute Name=\"" + name + "\"><![CDATA[" + value + "]" + "]></Attribute>"
				result = new XML( value );
			}
			else
			{
				result = <Attribute Name={_name}>{value}</Attribute>;
			}

			return result;
		}

		public function clone() : AttributeVO
		{
			var attributeVO : AttributeVO = new AttributeVO( _name, _defaultValue );
			attributeVO.value = _value;

			return attributeVO;

		}

		public function replaceValue() : void
		{
			var strTemp : String = _defaultValue;
			_defaultValue = _value;
			_value = strTemp;
		}

		public function get itemRenderer():Object
		{
			return _itemRenderer;
		}

		public function set itemRenderer(value:Object):void
		{
			_itemRenderer = value;
		}


	}
}
