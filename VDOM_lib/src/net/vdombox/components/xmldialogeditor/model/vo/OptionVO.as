package net.vdombox.components.xmldialogeditor.model.vo
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBoolVO;
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;

	public class OptionVO
	{
		private var _id : AttributeStringVO;
		private var _value : AttributeStringVO;
		private var _selected : AttributeBoolVO;
		private var _enabled : AttributeBoolVO;
		
		public function OptionVO( value : XML = null )
		{
			if ( value && value.@id[0] )
				id = new AttributeStringVO( "id", value.@id[0] );
			else
				id = new AttributeStringVO( "id", "1" );
			
			if ( value )
				this.value = new AttributeStringVO( "value", value[0].toString() );
			else
				this.value = new AttributeStringVO( "value", "item" );
			
			if ( value && value.@selected[0] && value.@selected == "true" )
				selected = new AttributeBoolVO( "selected", true );
			else
				selected = new AttributeBoolVO( "selected", false );
			
			if ( value && value.@enabled[0] && value.@enabled == "false" )
				enabled = new AttributeBoolVO( "enabled", false );
			else
				enabled = new AttributeBoolVO( "enabled", true );
		}

		public function get enabled():AttributeBoolVO
		{
			return _enabled;
		}

		public function set enabled(value:AttributeBoolVO):void
		{
			_enabled = value;
		}

		public function get selected():AttributeBoolVO
		{
			return _selected;
		}

		public function set selected(value:AttributeBoolVO):void
		{
			_selected = value;
		}

		public function get id():AttributeStringVO
		{
			return _id;
		}

		public function set id(value:AttributeStringVO):void
		{
			_id = value;
		}

		[Bindable]
		public function get value():AttributeStringVO
		{
			return _value;
		}

		public function set value(value:AttributeStringVO):void
		{
			_value = value;
		}
		
		private var _valueString : String;
		
		[Bindable]
		public function get valueString():String
		{
			return value.value;
		}
		
		public function set valueString( value : String ):void
		{
			_valueString = value;
		}

		public function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( value );
			_attributes.addItem( enabled );
			_attributes.addItem( selected );
			
			return _attributes;
		}
		
		public function toXML() : XML
		{
			var xml : XML = <Option>{ value.value }</Option>;
			
			xml.@id = id.value;
			xml.@selected = selected.value;
			xml.@enabled = enabled.value;
			
			return xml;
		}

	}
}