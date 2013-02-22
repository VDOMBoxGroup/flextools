package net.vdombox.components.xmldialogeditor.model.vo.properties
{
	import net.vdombox.components.xmldialogeditor.model.vo.attributes.AttributeBaseVO;
	
	public class PropertySingle extends AttributeBaseVO
	{
		private var _value : String;
		
		public function PropertySingle(name:String, value : String )
		{
			super(name);
			
			this.value = value;
		}
		
		[Bindable]
		public function get value():String
		{
			return _value;
		}
		
		public function set value(value:String):void
		{
			_value = value;
		}
	}
}