package net.vdombox.editors.parsers.vscript
{
	import flash.utils.Dictionary;
	
	import net.vdombox.editors.parsers.Token;
	
	import ro.victordramba.util.HashMap;

	public class VScriptToken extends Token
	{
		public static const STRING_LITERAL:String = "stringLiteral";
		public static const SYMBOL:String = "symbol";
		public static const STRING:String = "string";
		public static const NUMBER:String = "number";
		public static const KEYWORD:String = "keyword";
		public static const KEYWORD2:String = "keyword2";
		public static const ENDLINE:String = "endLine";
		public static const COMMENT:String = "comment";
		public static const NAMEFUNCTION:String = "nameFunction";
		public static const NAMECLASS:String = "nameClass";
		
		public static const REGEXP:String = "regexp";
		
		public static const E4X:String = "e4x";
		
		public var parent:VScriptToken;
		
		public var imports:HashMap;//used to solve names and types
		public var fromZone:Boolean = false;
		public var importZone:Boolean = false;
		public var importFrom:String = "";
		public var blockType : String = "";
		public var mainBlockType : String = "";
		public var blockClosed : Boolean = false;
		public var createConstruction : Boolean = false;
		
		public var error : Boolean = false;
		
		public static const map:Dictionary = new Dictionary(true);
		
		static private var count:Number = 0;
		
		
		public function VScriptToken(string:String, type:String, endPos:uint) 
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