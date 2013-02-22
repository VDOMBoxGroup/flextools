package net.vdombox.components.xmldialogeditor.model.vo
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBoolVO;

	public class OptionGroupVO extends OptionVO
	{
		private var _checked : AttributeBoolVO;
		
		public function OptionGroupVO(value:XML=null)
		{
			super(value);
			
			if ( value && value.@checked[0] && value.@checked == "true" )
				checked = new AttributeBoolVO( "checked", true );
			else
				checked = new AttributeBoolVO( "checked", false );
		}

		[Bindable]
		public function get checked():AttributeBoolVO
		{
			return _checked;
		}

		public function set checked(value:AttributeBoolVO):void
		{
			_checked = value;
		}

		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( value );
			_attributes.addItem( enabled );
			_attributes.addItem( checked );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = <Option>{ value.value }</Option>;
			
			xml.@id = id.value;
			xml.@checked = checked.value;
			xml.@enabled = enabled.value;
			
			return xml;
		}
	}
}