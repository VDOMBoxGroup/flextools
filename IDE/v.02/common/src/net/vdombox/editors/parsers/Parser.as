package net.vdombox.editors.parsers
{
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	
	import ro.victordramba.thread.IThread;
	import ro.victordramba.util.HashMap;

	public class Parser implements IThread
	{
		protected var tokenizer : Tokenizer;
		protected var tokenizer2 : Tokenizer;
		
		protected var formats : HashMap = new HashMap;
		protected var fileName : String;
		
		protected var _actionVO : Object;
		
		public function Parser()
		{
		}
		
		public function set colorScheme( colorSchemeVO : ColorSchemeVO ) : void
		{
			formats.setValue( 'default', new TextFormat( null, null, 0x111111, false, false ) );
			formats.setValue( Token.KEYWORD, new TextFormat( null, null, 0x1039FF, true, false ) );
			formats.setValue( Token.KEYWORD2, new TextFormat( null, null, 0x247ECE, true, false ) );
			formats.setValue( Token.E4X, new TextFormat( null, null, 0x613BB9, false, false ) );
			formats.setValue( Token.COMMENT, new TextFormat( null, null, 0x008000, false, true ) );
			formats.setValue( Token.REGEXP, new TextFormat( null, null, 0xa3a020, false, false ) );
			formats.setValue( Token.STRING, new TextFormat( null, null, 0x990000, false, false ) );
			formats.setValue( Token.NUMBER, new TextFormat( null, null, 0x990099, false, false ) );
			formats.setValue( Token.SYMBOL, new TextFormat( null, null, 0x006060, false, false ) );
			formats.setValue( Token.NAMEFUNCTION, new TextFormat( null, null, 0xFF00FF, false, false ) );
			formats.setValue( Token.NAMECLASS, new TextFormat( null, null, 0xFF7200, false, false ) );
			formats.setValue( 'topType', new TextFormat( null, null, 0x981056, false, false ) );
		}
		
		public function load( source : String, fileName : String ) : void
		{
		}
		
		public function applyFormats( textField : ScriptAreaComponent ) : void
		{
			textField.clearFormatRuns();
			
			for ( var i : int = 0; i < tokenizer.tokens.length; i++ )
			{
				var t : Token = tokenizer.tokens[ i ];
				var type : String = /*topType.test( t.string ) ? 'topType' : */t.type;
				var fmt : TextFormat = formats.getValue( type );
				if ( fmt )
					textField.addFormatRun( t.pos, t.pos + t.string.length, fmt.bold, fmt.italic, Number( fmt.color ).toString( 16 ), t.error );
					//textField.setTextFormat(fmt, t.pos, t.pos+t.string.length);
				else if ( t.string.indexOf( 'this.' ) == 0 )
				{
					fmt = formats.getValue( Token.KEYWORD );
					textField.addFormatRun( t.pos, t.pos + 4, fmt.bold, fmt.italic, Number( fmt.color ).toString( 16 ) );
					//textField.setTextFormat(formats.getValue(Token.KEYWORD), t.pos, t.pos+4);
				}
			}
			
			textField.applyFormatRuns();
		}
		
		public function runSlice() : Boolean
		{
			return false;
		}
		
		public function kill() : void
		{
		}
		
		public function get tokenCount() : uint
		{
			return tokenizer.tokens ? tokenizer.tokens.length : 0;
		}
		
		public function get percentReady() : Number
		{
			return ( tokenizer2 ? tokenizer2 : tokenizer ).precentReady;
		}
		
		private function get typeDB() : ClassDB
		{
			return tokenizer.classDB;
		}
		
		public function getTypeData() : ByteArray
		{
			return typeDB.toByteArray();
		}
		
		public function set actionVO( value : Object ) : void
		{
			_actionVO = value;
			tokenizer? tokenizer.actionVO = value : tokenizer2.actionVO = value;
		}
		
		public function getTokenByPos( pos : int ) : Token
		{	
			if ( tokenizer )
				return tokenizer.tokenByPos( pos ) as Token;
			else
				return tokenizer2.tokenByPos( pos ) as Token;
		}
	}
}