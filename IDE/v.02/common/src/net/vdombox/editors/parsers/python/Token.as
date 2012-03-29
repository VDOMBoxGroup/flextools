package net.vdombox.editors.parsers.python
{
	import flash.utils.Dictionary;
	
	import ro.victordramba.util.HashMap;

	internal class Token
	{
		public static const STRING_LITERAL:String = "stringLiteral";
		public static const SYMBOL:String = "symbol";
		public static const STRING:String = "string";
		public static const NUMBER:String = "number";
		public static const KEYWORD:String = "keyword";
		public static const KEYWORD2:String = "keyword2";
		public static const COMMENT:String = "comment";
		public static const NAMEFUNCTION:String = "nameFunction";
		public static const NAMECLASS:String = "nameClass";
		
		public static const REGEXP:String = "regexp";
		
		public static const E4X:String = "e4x";

		public var string:String;
		public var type:String;
		public var pos:uint;
		public var id:uint;

		public var children:Array/*of Token*/;
		public var parent:Token;

		public var scope:Field;//lexical scope
		public var imports:HashMap;//used to solve names and types

		public static const map:Dictionary = new Dictionary(true);

		static private var count:Number = 0;


		public function Token(string:String, type:String, endPos:uint) 
		{
			this.string = string;
			this.type = type;
			this.pos = endPos - string.length;
			id = count++;
			map[id] = this;
		}

		public function toString():String 
		{
			return string;
		}
	}
}