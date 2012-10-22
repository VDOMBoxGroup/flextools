package net.vdombox.editors.parsers.base
{
	import ro.victordramba.util.HashMap;

	public class Token
	{		
		public static const STRING_LITERAL:String = "stringLiteral";
		public static const SYMBOL:String = "symbol";
		public static const STRING:String = "string";
		public static const NUMBER:String = "number";
		public static const KEYWORD:String = "keyword";
		public static const KEYWORD2:String = "keyword2";
		public static const KEYWORD3:String = "keyword3";
		public static const ENDLINE:String = "endLine";
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
		
		public var scope:Field;//lexical scope
		
		public var parent:Token;
		
		public var error : Boolean = false;
		
		public function Token()
		{
		}
		
		public function findImport( name : String ) : Object
		{
			if ( !scope )
				return null;
			
			if ( scope.imports && scope.imports.hasKey( name ) )
				return scope.imports.getValue( name );
			else if ( parent )
				return parent.findImport( name );
			else
				return null;
		}
		
		public function hasMember( name : String ) : Boolean
		{
			if ( !scope )
				return false;
			
			return scope.members.hasKey( name );
		}
	}
}