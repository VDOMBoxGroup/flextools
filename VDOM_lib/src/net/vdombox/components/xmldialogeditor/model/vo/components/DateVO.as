package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeStringVO;
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentAddition;
	
	public class DateVO extends ComponentAddition
	{
		private var _value : AttributeStringVO;
		
		public function DateVO(value:XML)
		{
			super(value);
			
			name = "Date";
			
			if ( value.@value[0] )
				this.value = new AttributeStringVO( 'value', value.value );
		}

		public function get value():AttributeStringVO
		{
			return _value;
		}

		public function set value(value:AttributeStringVO):void
		{
			_value = value;
		}

	}
}