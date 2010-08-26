package net.vdombox.editors.parsers.vdomxml
{
	import ro.victordramba.util.HashMap;

	public class Multiname
	{
		public function Multiname(type:String=null, imports:HashMap=null)
		{
			this.imports = imports;
			this.type = type;
		}
		
		public var imports:HashMap;
		public var type:String;
		
		public function toString():String
		{
			return '[Multiname '+type+']';
		}
	}
}