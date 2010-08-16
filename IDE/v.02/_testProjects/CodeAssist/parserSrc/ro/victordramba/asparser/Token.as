/*
 * @Author Dramba Victor
 * 2009
 * 
 * You may use this code any way you like, but please keep this notice in
 * The code is provided "as is" without warranty of any kind.
 */

package ro.victordramba.asparser
{
	import flash.utils.Dictionary;
	
	import ro.victordramba.util.HashMap;

	internal class Token {
		public static const STRING_LITERAL:String = "stringLiteral";
		public static const SYMBOL:String = "symbol";
		public static const STRING:String = "string";
		public static const NUMBER:String = "number";
		public static const KEYWORD:String = "keyword";
		public static const KEYWORD2:String = "keyword2";
		public static const COMMENT:String = "comment";
		
		public static const REGEXP:String = "regexp";
		
		public static const E4X:String = "e4x";
		/*public static const E4X_TAG:String = "e4xTag";
		public static const E4X_TEXT:String = "e4xText";
		public static const E4X_CDATA:String = "e4xCdata";
		public static const E4X_COMMENT:String = "e4xComment";
		public static const E4X_COMMAND:String = "e4xCommand";*/

		public var string:String, type:String, pos:uint;
		public var id:uint;

		public var children:Array/*of Token*/;
		public var parent:Token;

		public var scope:Field;//lexical scope
		public var imports:HashMap;//used to solve names and types

		public static var map:Dictionary = new Dictionary(true);

		static private var count:Number = 0;


		public function Token(string:String, type:String, endPos:uint) {
			this.string = string;
			this.type = type;
			this.pos = endPos - string.length;
			id = count++;
			map[id] = this;
		}

		public function toString():String {
			return string;
		}
	}
}