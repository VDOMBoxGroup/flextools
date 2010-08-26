package net.vdombox.editors.parsers.vdomxml
{

	import ro.victordramba.util.HashMap;


	internal class Tokenizer
	{
		public function Tokenizer( string : String )
		{
			_typeDB = new TypeDB;

			this.string = string;
			position = 0;
		}

		public var tree : Token;

		internal var tokens : Array;
		internal var topScope : Field;

		private var currentBlock : Token;
		private var _scope : Field;
		private var field : Field;
		private var param : Field;
		private var defParamValue : String;
		private var paramsBlock : Boolean;
		private var imports : HashMap;
		private var scope : Field;
		private var isStatic : Boolean = false;
		private var access : String;

		private var _typeDB : TypeDB;

		private var string : String;
		private var position : uint;

		private var isTagInside : Boolean;

//		private static const keywordsA : Array = [
//			"and", "as", "assert", "break", "class", "continue", "def", "del", "elif",
//			"else", "except", "exec", "finally", "for", "from", "global", "if",
//			"import", "is", "in", "lambda", "not", "or", "pass", "print", "raise",
//			"return", "try", "while", "with", "yield",
//			"False", "True", "None"
//		];
//
//		private static const keywordsA:Array = [
//			"as", "is", "in", "break", "case", "continue", "default", "do", "while", "else", "for", "in", "each",
//			"if", "label", "return", "super", "switch", "throw", "try", "catch", "finally", "while",
//			"with", "dynamic", "final", "internal", "native", "override", "private", "protected",
//			"public", "static", "extends", "implements", "new",
//			"interface", "namespace", "default xml namespace", "import",
//			"include", "use", "delete", "use namespace", "false", "null", "this", "true", "undefined"];
//
//		private static const keywords2A : Array = [
//			"const", "package", "var", "function", "get", "set", "class" 
//			];

//		private static const symbolsA : Array = [
//			"+", "--", "/", "\\", "++", "%", "*", "-", "+=", "/=", "%=", "*=", "-=", "=", "&", "<<",
//			"~", "|", ">>", ">>>", "^", "&=", "<<=", "|=", ">>=", ">>>=", "^=", "==", ">",
//			">=", "!=", /*"<", special, can start an E4X*/ "<=", "===", "!==", "&&", "&&=", "!", "||", "||=", "[", "]",
//			"as", ",", "?", ".", "instanceof", "::", "new", "{", "}",
//			"(", ")", "typeof", ";", ":", "...", "..", "#", "`" /*just to unlock*/ ];
//		private static const symbolsA : Array = [
//			"+", "-", "/", "*", "=", "<", ">", "%", "!", "&", ";", "?", "`", ":", "," ];

//		private static const keywords : HashMap = new HashMap();
//		private static const keywords2 : HashMap = new HashMap();
//		private static const symbols : HashMap = new HashMap();
//		private static const symbolsLengths : Array = [];

		//static class init
//		private static var init : Boolean = ( function() : Boolean
//		{
//			var s : String;
//			
//			for each ( s in keywordsA )
//			{
//				keywords.setValue( s, true );
//			}
//			
//			for each ( s in keywords2A )
//			{
//				keywords2.setValue( s, true );
//			}
//			
//			for each ( s in symbolsA )
//			{
//				symbols.setValue( s, true );
//				
//				var len : uint = s.length;
//				
//				if ( symbolsLengths.indexOf( len ) == -1 )
//					symbolsLengths.push( len );
//			}
//			symbolsLengths.sort( Array.DESCENDING + Array.NUMERIC );
//
//			return true;
//		} )();

		public function get precentReady() : Number
		{
			return position / string.length;
		}

		public function nextToken() : Token
		{
			if ( position >= string.length )
				return null;

			var char : String = getCurrentChar();
			var startPosition : uint = position;
			var tempPosition : uint = position;

			var tokenString : String;
			var prevToken : Token;

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

						return new Token( tokenString, Token.CDATA, position );
					}
					else if ( ( string.length - position > 3 && string.substr( position + 1, 3 ) == "!--" ) )
					{
						skipUntil( "-->" );
						tokenString = string.substring( startPosition, position );

						return new Token( tokenString, Token.COMMENT, position );
					}
				}
				else if ( nextChar() == "?" )
				{
					skipUntil( "?>" );
					tokenString = string.substring( startPosition, position );

					return new Token( tokenString, Token.PROCESSING_INSTRUCTIONS, position );
				}
				else if ( nextChar() == "/" )
				{
					position += 2;
					tokenString = string.substring( startPosition, position );

					return new Token( tokenString, Token.TAGNAME, position );
				}
				else
				{
					tokenString = string.substring( startPosition, ++position );

					return new Token( tokenString, Token.TAGNAME, position );
				}

			}

			else if ( char == "/" && nextChar() == ">" )
			{
				position += 2;
				tokenString = string.substring( startPosition, position );

				return new Token( tokenString, Token.TAGNAME, position );
			}

			else if ( char == ">" )
			{
				tokenString = string.substring( startPosition, ++position );
				isTagInside = false;

				return new Token( tokenString, Token.TAGNAME, position );
			}

			else if ( char == "\"" && isTagInside )
			{
				skipUntil( "\"" );
				tokenString = string.substring( startPosition, position );

				return new Token( tokenString, Token.ATTRIBUTEVALUE, position );
			}

			else if ( isLetter( char ) )
			{
				prevToken = tokens.length > 0 ? tokens[ tokens.length - 1 ] : null;

				if ( !prevToken )
				{
					skipUntil( "<" );
					tokenString = string.substring( startPosition, position );

					return new Token( tokenString, Token.COMMENT, position );
				}

				if ( prevToken.string == "<" )
				{
					skipToStringEnd();
					tokenString = string.substring( startPosition, position );

					isTagInside = true;

					return new Token( tokenString, Token.TAGNAME, position );
				}
				else if ( prevToken.string == "</" )
				{
					skipToStringEnd();
					tokenString = string.substring( startPosition, position );

					tempPosition = position;

					if ( getCurrentChar() != ">" )
						skipUntil( ">" );

					return new Token( tokenString, Token.TAGNAME, tempPosition );
				}
				else if ( isTagInside )
				{
					if ( isLetter( char ) )
					{
						skipToStringEnd();
						tokenString = string.substring( startPosition, position );

						if ( prevToken.string == "\"" )
							return new Token( tokenString, Token.ATTRIBUTEVALUE, position );
						else
							return new Token( tokenString, Token.ATTRIBUTENAME, position );
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
			return new Token( char, Token.SYMBOL, ++position );
		}

		public function tokenByPos( pos : uint ) : Token
		{
			if ( !tokens || tokens.length < 3 )
				return null;
			//TODO: binary search
			for ( var i : int = tokens.length - 1; i >= 0; i-- )
				if ( tokens[ i ] && pos > tokens[ i ].pos )
					return Token.map[ tokens[ i ].id ];
			return null;
		}

		internal function get typeDB() : TypeDB
		{
			return _typeDB;
		}

		internal function runSlice() : Boolean
		{
			//init (first run)
			if ( !tokens )
			{
				tokens = [];
				tree = new Token( "top", null, 0 );
				tree.children = [];
				currentBlock = tree;

				//top scope
				topScope = scope = new Field( "top", 0, "top" );
				//toplevel package
				scope.members.setValue( "", new Field( "package", 0, "" ) );

				position = 0;
				defParamValue = null;
				paramsBlock = false;

				imports = new HashMap();
			}

			var t : Token = nextToken();
			if ( !t )
				return false;

			tokens.push( t );
			t.parent = currentBlock;
			currentBlock.children.push( t );
			if ( t.string == "{" /* || t.string=="[" || t.string=="("*/ )
			{
				currentBlock = t;
				t.children = [];
			}
			if ( t.string == "}" && currentBlock.parent /* || t.string=="]" || t.string==")"*/ )
			{
				currentBlock = currentBlock.parent;
			}

			t.scope = scope;

			var tokensLength : uint = tokens.length - 1;
			var tp : Token = tokens[ tokensLength - 1 ];
			var tp2 : Token = tokens[ tokensLength - 2 ];
			var tp3 : Token = tokens[ tokensLength - 3 ];

			if ( t.string == "package" )
				imports = new HashMap;

			//toplevel package
			if ( t.string == "{" && tp.string == "package" )
			{
				_scope = scope.members.getValue( "" );
					//imports.setItem(".*");
			}
			else if ( tp && tp.string == "import" )
			{
				imports.setValue( t.string, t.string );
			}
			else if ( tp && tp.string == "extends" )
			{
				field.extendz = new Multiname( t.string, imports );
			}
			else if ( t.string == "private" || t.string == "protected" || t.string == "public" || t.string == "internal" )
			{
				access = t.string;
			}
			else if ( t.string == "static" )
			{
				isStatic = true;
			}
			else if ( t.string == "get" || t.string == "set" )
			{
				//do nothing
			}
			else if ( tp && ( tp.string == "package" || tp.string == "class" || tp.string == "interface" ||
				tp.string == "function" || tp.string == "catch" || tp.string == "get" || tp.string == "set" ||
				tp.string == "var" || tp.string == "const" ) )
			{
				//for package, merge classes in the existing omonimus package
				if ( tp.string == "package" && scope.members.hasKey( t.string ) )
					_scope = scope.members.getValue( t.string );
				else
				{
					//debug("field-"+tp.string);
					//TODO if is "set" make it "*set"
					field = new Field( tp.string, t.pos, t.string );
					if ( t.string != "(" ) //anonimus functions are not members
						scope.members.setValue( t.string, field );
					if ( tp.string != "var" && tp.string != "const" )
						_scope = field;

					if ( isStatic ) //consume "static" declaration
					{
						field.isStatic = true;
						isStatic = false;
					}
					if ( access ) //consume access specifier
					{
						field.access = access;
						access = null;

					}
					//all interface methods are public
					if ( scope.fieldType == "interface" )
						field.access = "public";
					//this is so members will have the parent set to the scope
					field.parent = scope;
				}
				if ( _scope && ( tp.string == "class" || tp.string == "interface" || scope.fieldType == "package" ) )
				{
					_scope.type = new Multiname( "Class" );
					try
					{
						_typeDB.addDefinition( scope.name, field );
					}
					// failproof for syntax errors
					catch ( e : Error )
					{
					}
				}
				//add current package to imports
				if ( tp.string == "package" )
					imports.setValue( t.string + ".*", t.string + ".*" );
			}

			if ( t.string == ";" )
			{
				field = null;
				_scope = null;
				isStatic = false;
			}

			//parse function params
			else if ( _scope && ( _scope.fieldType == "function" || _scope.fieldType == "catch" || _scope.fieldType == "set" ) )
			{
				if ( tp && tp.string == "(" && t.string != ")" )
					paramsBlock = true;

				if ( paramsBlock )
				{
					if ( !param && t.string != "..." )
					{
						param = new Field( "var", position, t.string );
						t.scope = _scope;
						_scope.params.setValue( param.name, param );
						if ( tp.string == "..." )
						{
							_scope.hasRestParams = true;
							param.type = new Multiname( "Array" );
						}
					}
					else if ( tp.string == ":" )
					{
						if ( _scope.fieldType == "set" )
						{
							_scope.type = new Multiname( t.string, imports );
						}
						else
							param.type = new Multiname( t.string, imports );
					}

					else if ( t.string == "=" )
						defParamValue = "";

					else if ( t.string == "," || t.string == ")" )
					{
						if ( t.string == ")" )
						{
							paramsBlock = false;
						}
						if ( defParamValue )
						{
							param.defaultValue = defParamValue;
							defParamValue = null;
						}
						param = null;
					}
					else if ( defParamValue != null )
						defParamValue += t.string;
				}
			}


			if ( field && tp3 && tp.string == ":" )
			{
				if ( tp3.string == "var" || tp3.string == "const" || tp2.string == ")" )
				{
					if ( field.fieldType != "set" )
					{
						field.type = new Multiname( t.string, imports );
					}
					field = null;
				}
			}


			if ( t.string == "{" && _scope )
			{
				currentBlock.imports = imports;
				_scope.pos = t.pos;
				_scope.parent = scope;
				scope = _scope;
				t.scope = scope;
				//info += pos + ")" + scope.parent.name + "->" + scope.name+"\n";
				_scope = null;
			}

			else if ( t.string == "}" && t.parent.pos == scope.pos )
			{
				//info += scope.parent.name + "<-" + scope.name+"\n";
				scope = scope.parent;

				//force a ; to close the scope here. needs further testing
				var sepT : Token = new Token( ";", Token.SYMBOL, t.pos + 1 );
				sepT.scope = scope;
				sepT.parent = t.parent;
				tokens.push( sepT );
			}

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