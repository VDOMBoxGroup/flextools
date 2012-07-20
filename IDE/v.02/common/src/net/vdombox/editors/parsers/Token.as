package net.vdombox.editors.parsers
{
	public class Token
	{
		public var string:String;
		public var type:String;
		public var pos:uint;
		public var id:uint;
		
		public var posVariable:int = -1;
		
		public var children:Array/*of Token*/;
		
		public var scope:Field;//lexical scope
		
		public function Token()
		{
		}
	}
}