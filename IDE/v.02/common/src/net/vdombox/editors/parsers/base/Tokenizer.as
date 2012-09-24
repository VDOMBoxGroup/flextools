package net.vdombox.editors.parsers.base
{
	import net.vdombox.editors.parsers.vdomxml.TypeDB;
	
	import ro.victordramba.util.HashMap;
	import net.vdombox.editors.parsers.ClassDB;

	public class Tokenizer
	{
		protected var string : String;
		protected var pos : uint;
		protected var str : String;
		protected var prevStr : String;
		
		protected var _members : HashMap;
		
		public var actionVO : Object;
		
		public var tokens : Array;
		protected var _classDB : ClassDB;
		protected var _typeDB : TypeDB;
		
		
		public function Tokenizer()
		{
		}
		
		public function get classDB() : ClassDB
		{
			return _classDB;
		}
		
		public function get typeDB() : TypeDB
		{
			return _typeDB;
		}
		
		public function runSlice() : Boolean
		{
			return false;
		}
		
		public function tokenByPos( pos : uint ) : Token
		{
			return null;
		}
	}
}