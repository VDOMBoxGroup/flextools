package net.vdombox.editors.parsers
{
	public class AutoCompleteItemVO
	{
		public var icon : Class;
		public var value : String;
		
		public function AutoCompleteItemVO( icon : Class = null, value : String = "" )
		{
			this.icon = icon;
			this.value = value;
		}
	}
}