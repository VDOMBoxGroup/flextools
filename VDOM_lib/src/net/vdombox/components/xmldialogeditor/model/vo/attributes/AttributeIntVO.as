package net.vdombox.components.xmldialogeditor.model.vo.attributes
{
	public class AttributeIntVO extends AttributeBaseVO
	{
		private var _value : int;
		
		public function AttributeIntVO(name:String, value : int )
		{
			super(name);
			
			this.value = value;
		}

		[Bindable]
		public function get value():int
		{
			return _value;
		}

		public function set value(value:int):void
		{
			_value = value;
		}

	}
}