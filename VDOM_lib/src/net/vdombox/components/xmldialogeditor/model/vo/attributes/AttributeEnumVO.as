package net.vdombox.components.xmldialogeditor.model.vo.attributes
{
	public class AttributeEnumVO extends AttributeBaseVO
	{
		private var _value : String;
		private var _source : Array;
		
		public function AttributeEnumVO(name:String, value : String, source : Array )
		{
			super(name);
			
			this.value = value;
			this.source = source;
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

		public function get source():Array
		{
			return _source;
		}

		public function set source(value:Array):void
		{
			_source = value;
		}

	}
}