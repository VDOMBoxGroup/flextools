package net.vdombox.components.xmldialogeditor.model.vo.components.base
{
	import mx.collections.ArrayCollection;

	public class ComponentBase
	{
		private var _name : String;
		
		public function ComponentBase( value : XML )
		{
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

		public function get attributes() : ArrayCollection
		{
			return new ArrayCollection();
		}

		public function toXML() : XML
		{
			return new XML();
		}
	}
}