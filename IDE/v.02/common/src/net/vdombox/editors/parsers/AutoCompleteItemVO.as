package net.vdombox.editors.parsers
{
	import net.vdombox.ide.common.view.components.VDOMImage;

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