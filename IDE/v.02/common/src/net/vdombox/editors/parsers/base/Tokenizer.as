package net.vdombox.editors.parsers.base
{
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.TypeDB;
	
	import ro.victordramba.util.HashMap;

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
		
		private var _prevImport : Object;
		
		
		public function Tokenizer()
		{
		}
		
		public function get prevImport():Object
		{
			return _prevImport;
		}
		
		public function set prevImport(value:Object):void
		{
			_prevImport = value;
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
		
		public function addPrevImport( name : String ) : void
		{
			if ( !_prevImport )
				_prevImport = {};
			
			_prevImport[ name ] = name;
		}
		
		public function hasPrevImport( name : String ) : Boolean
		{
			if ( _prevImport )
				return _prevImport.hasOwnProperty( name );
			else
				return false;
		}
	}
}