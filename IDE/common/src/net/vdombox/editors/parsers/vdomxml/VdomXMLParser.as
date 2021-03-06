package net.vdombox.editors.parsers.vdomxml
{
	import flash.text.*;
	import flash.utils.setTimeout;

	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.editors.parsers.TypeDB;

	import ro.victordramba.thread.IThread;
	import ro.victordramba.util.HashMap;

	public class VdomXMLParser implements IThread
	{
		private var tokenizer : VdomXMLTokenizer;

		private var tokenizer2 : VdomXMLTokenizer;


		private var formats : HashMap = new HashMap;

		private var fileName : String;

		public function VdomXMLParser()
		{
			//syntax highlighting
			formats.setValue( 'default', new TextFormat( null, null, 0x111111, false, false ) );
			formats.setValue( VdomXMLToken.TAGNAME, new TextFormat( null, null, 0x952a57, true, false ) );
			formats.setValue( VdomXMLToken.CLOSETAG, new TextFormat( null, null, 0x952a57, true, false ) );
			formats.setValue( VdomXMLToken.OPENTAG, new TextFormat( null, null, 0x952a57, true, false ) );
			formats.setValue( VdomXMLToken.ATTRIBUTENAME, new TextFormat( null, null, 0x9f992f, true, false ) );
			formats.setValue( VdomXMLToken.ATTRIBUTEVALUE, new TextFormat( null, null, 0x657bd4, false, false ) );
			formats.setValue( VdomXMLToken.PROCESSING_INSTRUCTIONS, new TextFormat( null, null, 0xa3a020, false, true ) );
			formats.setValue( VdomXMLToken.COMMENT, new TextFormat( null, null, 0xAAAAAA, false, true ) );
			formats.setValue( VdomXMLToken.CDATA, new TextFormat( null, null, 0x439f15, false, false ) );
			formats.setValue( VdomXMLToken.SYMBOL, new TextFormat( null, null, 0x9f992f, false, false ) );
			formats.setValue( VdomXMLToken.EQUAL, new TextFormat( null, null, 0x9f992f, false, false ) );
			formats.setValue( 'topType', new TextFormat( null, null, 0x981056, false, false ) );
		}

		public static function addSourceFile( source : String, fileName : String, onComplete : Function ) : void
		{
			source = source.replace( /(\n|\r\n)/g, '\r' );
			var parser : VdomXMLParser = new VdomXMLParser;
			parser.load( source, fileName );
			while ( parser.runSlice() )
			{
			}
			setTimeout( onComplete, 1 );
		}


		//private var typeDB:TypeDB;

		private static const topType : RegExp = /^(:?int|uint|Number|Boolean|RegExp|String|void|Function|Class|Array|Date|ByteArray|Vector|Object|XML|XMLList|Error)$/;

		public function load( source : String, fileName : String ) : void
		{
			tokenizer2 = new VdomXMLTokenizer( source );
			this.fileName = fileName;
		}

		private function get typeDB() : TypeDB
		{
			return tokenizer.typeDB;
		}



		/*
		   public function addTypeData(db:TypeDB, name:String):void
		   {

		   }
		 */


		/**
		 * Apply color highliting
		 */
		public function applyFormats( textField : ScriptAreaComponent ) : void
		{
			//textField.setTextFormat(formats.getValue('default'));
			textField.clearFormatRuns();

			for ( var i : int = 0; i < tokenizer.tokens.length; i++ )
			{
				var t : VdomXMLToken = tokenizer.tokens[ i ];
				var type : String = topType.test( t.string ) ? 'topType' : t.type;
				var fmt : TextFormat = formats.getValue( type );
				if ( fmt )
					textField.addFormatRun( t.pos, t.pos + t.string.length, fmt.bold, fmt.italic, Number( fmt.color ).toString( 16 ) );
				//textField.setTextFormat(fmt, t.pos, t.pos+t.string.length);
				else if ( t.string.indexOf( 'this.' ) == 0 )
				{
					fmt = formats.getValue( VdomXMLToken.SYMBOL );
					textField.addFormatRun( t.pos, t.pos + 4, fmt.bold, fmt.italic, Number( fmt.color ).toString( 16 ) );
						//textField.setTextFormat(formats.getValue(Token.KEYWORD), t.pos, t.pos+4);
				}
			}

			textField.applyFormatRuns();
		}


		public function get tokenCount() : uint
		{
			return tokenizer.tokens ? tokenizer.tokens.length : 0;
		}

		public function get percentReady() : Number
		{
			return ( tokenizer2 ? tokenizer2 : tokenizer ).precentReady;
		}


		public function runSlice() : Boolean
		{
			var b : Boolean = tokenizer2.runSlice();
			if ( !b )
			{
				tokenizer = tokenizer2;
				tokenizer2 = null;
				TypeDB.setDB( fileName, tokenizer.typeDB );
			}
			return b;
		}

		public function kill() : void
		{
		/*
		   if (tokenizer2)
		   {
		   tokenizer2.kill();
		   tokenizer2 = null;
		   }
		 */
		}

		/*
		   public function getNodeByPos(pos:uint):Token
		   {
		   if (!tokenizer) return null;
		   return tokenizer.tokenByPos(pos);
		   }
		 */



		public function newResolver() : Resolver
		{
			return new Resolver( tokenizer );
		}
	}
}