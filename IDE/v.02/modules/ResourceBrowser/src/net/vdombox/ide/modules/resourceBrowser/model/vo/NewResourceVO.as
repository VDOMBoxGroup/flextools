package net.vdombox.ide.modules.resourceBrowser.model.vo
{
	[Bindable]
	public class NewResourceVO
	{
		public function NewResourceVO( name : String = null, path : String = null, size : Number = NaN )
		{
			this.name = name;
			this.path = path;
			this.size = size;
		}
		
		public var name : String;
		public var path : String;
		public var size : Number;
	}
}