package net.vdombox.components.xmldialogeditor.model.vo.attributes
{
	public class AttributeBoolVO extends AttributeBaseVO
	{
		private var _value : Boolean;
		
		public function AttributeBoolVO(name:String, value : Boolean )
		{
			super(name);
			
			this.value = value;
		}
		
		[Bindable]
		public function get value():Boolean
		{
			return _value;
		}
		
		public function set value(value:Boolean):void
		{
			_value = value;
		}
	}
}