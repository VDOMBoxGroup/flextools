package net.vdombox.editors.parsers
{

	public class ImportItemVO
	{
		public var name : String;

		public var systemName : String;

		public var source : String;

		public function ImportItemVO( name : String, systemName : String, source : String )
		{
			this.name = name;
			this.systemName = systemName;
			this.source = source;
		}
	}
}
