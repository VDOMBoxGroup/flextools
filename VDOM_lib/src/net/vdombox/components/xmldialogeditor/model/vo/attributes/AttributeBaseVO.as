package net.vdombox.components.xmldialogeditor.model.vo.attributes
{
	public class AttributeBaseVO
	{
		private var _name : String;
		
		public function AttributeBaseVO( name : String ) : void
		{
			this.name = name;
		}
		
		[Bindable]
		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

	}
}