package net.vdombox.editors.parsers
{
	import ro.victordramba.util.HashMap;

	public class Token
	{
		public var string:String;
		public var type:String;
		public var pos:uint;
		public var id:uint;
		
		public var posVariable:int = -1;
		
		public var children:Array/*of Token*/;
		
		public var scope:Field;//lexical scope
		
		public var parent:Token;
		
		public var imports:HashMap;//used to solve names and types
		
		public function Token()
		{
		}
	}
}