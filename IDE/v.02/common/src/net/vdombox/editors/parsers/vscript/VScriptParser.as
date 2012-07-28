package net.vdombox.editors.parsers.vscript
{
	import flash.text.*;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.Parser;
	import net.vdombox.editors.parsers.Token;
	
	import ro.victordramba.thread.IThread;
	import ro.victordramba.util.HashMap;
	
	public class VScriptParser extends Parser
	{				
		public function VScriptParser()
		{
		}
		
		public static function addSourceFile( source : String, fileName : String, onComplete : Function ) : void
		{
			source = source.replace( /(\n|\r\n)/g, '\r' );
			var parser : VScriptParser = new VScriptParser;
			parser.load( source, fileName );
			while ( parser.runSlice() )
			{
			}
			setTimeout( onComplete, 1 );
		}
		
		
		//private var typeDB:TypeDB;
		
		private static const topType : RegExp =
			/^(:?int|uint|Number|Boolean|RegExp|String|void|Function|Class|Array|Date|ByteArray|Vector|Object|XML|XMLList|Error)$/;
		
		public override  function load( source : String, fileName : String ) : void
		{
			tokenizer2 = new VScriptTokenizer( source );
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
		
		/*public function getNodeByPos(pos:uint):Token
		{
		if (!tokenizer) return null;
		return tokenizer.tokenByPos(pos);
		}*/
		
		
		
		public function newResolver() : Resolver
		{
			return new Resolver( tokenizer as VScriptTokenizer );
		}
	}
}