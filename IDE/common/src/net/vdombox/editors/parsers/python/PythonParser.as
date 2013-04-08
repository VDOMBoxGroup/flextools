package net.vdombox.editors.parsers.python
{
	import flash.text.*;
	import flash.utils.setTimeout;

	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.base.Parser;

	public class PythonParser extends Parser
	{
		public function PythonParser()
		{
			var tt : int = 0;
		}

		public static function addSourceFile( source : String, fileName : String, onComplete : Function ) : void
		{
			source = source.replace( /(\n|\r\n)/g, '\r' );
			var parser : PythonParser = new PythonParser;
			parser.load( source, fileName );
			while ( parser.runSlice() )
			{
			}
			setTimeout( onComplete, 1 );
		}


		//private var typeDB:TypeDB;

		private static const topType : RegExp = /^(:?int|uint|Number|Boolean|RegExp|String|void|Function|Class|Array|Date|ByteArray|Vector|Object|XML|XMLList|Error)$/;

		public override function load( source : String, fileName : String ) : void
		{
			tokenizer2 = new PythonTokenizer( source );
			tokenizer2.actionVO = _actionVO;
			this.fileName = fileName;
		}

		public override function runSlice() : Boolean
		{
			var b : Boolean = tokenizer2.runSlice();
			if ( !b )
			{
				tokenizer = tokenizer2;
				tokenizer2 = null;
				ClassDB.setDB( fileName, tokenizer.classDB );
			}
			return b;
		}

		public function newResolver() : Resolver
		{
			return new Resolver( tokenizer as PythonTokenizer );
		}
	}
}