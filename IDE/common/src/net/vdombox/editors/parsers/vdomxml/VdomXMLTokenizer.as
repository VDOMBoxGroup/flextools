package net.vdombox.editors.parsers.vdomxml
{

	import net.vdombox.editors.parsers.TypeDB;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.editors.parsers.base.Tokenizer;


	public class VdomXMLTokenizer extends Tokenizer
	{
		public function VdomXMLTokenizer( string : String )
		{
			_typeDB = new TypeDB;

			this.string = string;
			position = 0;
		}

		public var tree : VdomXMLToken;

		internal var topScope : Field;

		private var currentBlock : VdomXMLToken;

		private var _scope : Field;

		private var field : Field;

		private var param : Field;

		private var defParamValue : String;

		private var paramsBlock : Boolean;

		private var scope : Field;

		private var isStatic : Boolean = false;

		private var access : String;

		private var position : uint;

		private var isTagInside : Boolean;

		public function get precentReady() : Number
		{
			return position / string.length;
		}

		public function nextToken() : VdomXMLToken
		{
			if ( position >= string.length )
				return null;

			var char : String = getCurrentChar();
			var startPosition : uint = position;
			var tempPosition : uint = position;

			var tokenString : String;
			var prevToken : VdomXMLToken;

			if ( isWhitespace( char ) )
			{
				skipWhitespace();
				startPosition = position;
				char = getCurrentChar();
			}

			if ( char == "<" )
			{
				if ( nextChar() == "!" )
				{
					if ( string.length - position > 8 && string.substr( position + 1, 8 ) == "![CDATA[" )
					{
						skipUntil( "\]\]>" );
						tokenString = string.substring( startPosition, position );

						return new VdomXMLToken( tokenString, VdomXMLToken.CDATA, position );
					}
					else if ( ( string.length - position > 3 && string.substr( position + 1, 3 ) == "!--" ) )
					{
						skipUntil( "-->" );
						tokenString = string.substring( startPosition, position );

						return new VdomXMLToken( tokenString, VdomXMLToken.COMMENT, position );
					}
				}
				else if ( nextChar() == "?" )
				{
					skipUntil( "?>" );
					tokenString = string.substring( startPosition, position );

					return new VdomXMLToken( tokenString, VdomXMLToken.PROCESSING_INSTRUCTIONS, position );
				}
				else if ( nextChar() == "/" )
				{
					skipUntil( ">" );
					tokenString = string.substring( startPosition, position );

					return new VdomXMLToken( tokenString, VdomXMLToken.CLOSETAG, position );
				}
				else
				{
					tokenString = string.substring( startPosition, ++position );

					return new VdomXMLToken( tokenString, VdomXMLToken.OPENTAG, position );
				}

			}

			else if ( char == "/" && nextChar() == ">" )
			{
				position += 2;
				tokenString = string.substring( startPosition, position );

				return new VdomXMLToken( tokenString, VdomXMLToken.CLOSETAG, position );
			}

			else if ( char == ">" )
			{
				tokenString = string.substring( startPosition, ++position );
				isTagInside = false;

				return new VdomXMLToken( tokenString, VdomXMLToken.TAGNAME, position );
			}

			else if ( char == "\"" && isTagInside )
			{
				skipUntil( "\"" );
				tokenString = string.substring( startPosition, position );

				return new VdomXMLToken( tokenString, VdomXMLToken.ATTRIBUTEVALUE, position );
			}

			else if ( char == "=" && isTagInside )
			{
				tokenString = string.substring( startPosition, ++position );

				return new VdomXMLToken( tokenString, VdomXMLToken.EQUAL, position );
			}

			else if ( isLetter( char ) )
			{
				prevToken = tokens.length > 0 ? tokens[ tokens.length - 1 ] : null;

				if ( !prevToken )
				{
					skipUntil( "<" );
					tokenString = string.substring( startPosition, position );

					return new VdomXMLToken( tokenString, VdomXMLToken.COMMENT, position );
				}

				if ( prevToken.string == "<" )
				{
					skipToStringEnd();
					tokenString = string.substring( startPosition, position );

					isTagInside = true;

					return new VdomXMLToken( tokenString, VdomXMLToken.TAGNAME, position );
				}
				else if ( prevToken.string == "</" )
				{
					skipToStringEnd();
					tokenString = string.substring( startPosition, position );

					tempPosition = position;

					if ( getCurrentChar() != ">" )
						skipUntil( ">" );

					return new VdomXMLToken( tokenString, VdomXMLToken.TAGNAME, tempPosition );
				}
				else if ( isTagInside )
				{
					if ( isLetter( char ) )
					{
						skipToStringEnd();
						tokenString = string.substring( startPosition, position );

						if ( prevToken.string == "\"" )
							return new VdomXMLToken( tokenString, VdomXMLToken.ATTRIBUTEVALUE, position );
						else
							return new VdomXMLToken( tokenString, VdomXMLToken.ATTRIBUTENAME, position );
					}

				}

			}
			//			if ( isWhitespace( char ) )
			//			{
			//				skipWhitespace();
			//
			//				char = getCurrentChar();
			//
			//				startPosition = position;
			//			}


			//unknown
			return new VdomXMLToken( char, VdomXMLToken.SYMBOL, ++position );
		}

		public override function tokenByPos( pos : uint ) : Token
		{
			if ( !tokens || tokens.length < 3 )
				return null;
			//TODO: binary search
			for ( var i : int = tokens.length - 1; i >= 0; i-- )
				if ( tokens[ i ] && pos > tokens[ i ].pos )
					return VdomXMLToken.map[ tokens[ i ].id ];
			return null;
		}

		public override function runSlice() : Boolean
		{
			//init (first run)
			if ( !tokens )
			{
				tokens = [];
				tree = new VdomXMLToken( "top", null, 0 );
				tree.children = [];
				currentBlock = tree;

				//top scope
				topScope = scope = new Field( "top", 0, "top" );

				position = 0;
				defParamValue = null;
				paramsBlock = false;
			}

			var t : VdomXMLToken = nextToken();
			if ( !t )
				return false;

			tokens.push( t );
			t.parent = currentBlock;
			currentBlock.children.push( t );

			if ( t.string == "<" )
			{
				currentBlock = t;
				t.children = [];
			}

			else if ( ( t.string == ">" || t.string == "/>" ) && currentBlock.parent )
			{
				currentBlock = currentBlock.parent as VdomXMLToken;
			}

			t.scope = scope;

			return true;
		}

		internal function kill() : void
		{
			tokens = null;
		}

		private function getCurrentChar() : String
		{
			return string.charAt( position );
		}

		private function nextChar() : String
		{
			if ( position >= string.length - 1 )
				return null;

			return string.charAt( position + 1 );
		}

		private function skipUntil( exit : String ) : void
		{
			position++;

			var p : int = string.indexOf( exit, position );

			if ( p == -1 )
				position = string.length;
			else
				position = p + exit.length;
		}

		//		private function skipUntilWithEscNL( exit : String ) : void
		//		{
		//			//this is faster than regexp
		//			pos++;
		//			var c : String;
		//			while ( ( c = string.charAt( pos ) ) != exit && c != "\r" && c )
		//			{
		//				if ( c == "\\" )
		//					pos++;
		//				pos++;
		//			}
		//			if ( c )
		//				pos++;
		//		}

		private function skipWhitespace() : void
		{
			var char : String;

			char = getCurrentChar();

			while ( isWhitespace( char ) )
			{
				position++;
				char = getCurrentChar();
			}
		}

		private function isWhitespace( str : String ) : Boolean
		{
			return str == " " || str == "\n" || str == "\t" || str == "\r";
		}

		private function skipToStringEnd() : void
		{
			var char : String;

			while ( true )
			{
				char = getCurrentChar();

				if ( !( isLetter( char ) || isNumber( char ) || char == "." || ( char == "-" ) ) )
					break;

				position++;
			}
		}

		private function isNumber( str : String ) : Boolean
		{
			var code : uint = str.charCodeAt( 0 );
			return ( code >= 48 && code <= 57 );
		}

		private function isLetter( str : String ) : Boolean
		{
			var code : uint = str.charCodeAt( 0 );
			if ( code == 58 || code == 95 ) //: _
				return true;
			if ( code >= 65 && code <= 90 ) //A-Z
				return true;
			if ( code >= 97 && code <= 122 ) //a-z 
				return true;
			return false;
		}

		//		private function isKeyword( str : String ) : Boolean
		//		{
		//			return keywords.getValue( str );
		//		}
		//
		private function lengthSort( strA : String, strB : String ) : int
		{
			if ( strA.length < strB.length )
				return 1;
			if ( strA.length > strB.length )
				return -1;
			return 0;
		}


	}
}