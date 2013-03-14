package net.vdombox.editors.parsers.python
{

	import ro.victordramba.util.HashMap;


	internal class Tokenizer
	{
		public var tree : Token;

		private var string : String;
		private var pos : uint;
		private var str : String;
		private var prevStr : String;

		private static const keywordsA : Array = [
			"and", "as", "del", "for", "is", "raise", "assert", "elif", "from", "lambda", "return", "break", "else", "global", "None", "not", "try", "True", "False", "class", "except", "if", "or", "while", "continue", "exec", "import", "pass", "yield", "def", "finally", "in", "print"
		];

		private static const keywords2A : Array = [
			"self" 
			];

		private static const symbolsA : Array = [
			"+", "-", "/", "*", "=", "<", ">", "%", "!", "&", ";", "?", "`", ":", ",", "." ];

		private static const keywords : HashMap = new HashMap();
		private static const keywords2 : HashMap = new HashMap();
		private static const symbols : HashMap = new HashMap();
		private static const symbolsLengths : Array = [];

		//static class init
		private static var init : Boolean = ( function() : Boolean
		{
			var s : String;
			
			for each ( s in keywordsA )
			{
				keywords.setValue( s, true );
			}
			
			for each ( s in keywords2A )
			{
				keywords2.setValue( s, true );
			}
			
			for each ( s in symbolsA )
			{
				symbols.setValue( s, true );
				
				var len : uint = s.length;
				
				if ( symbolsLengths.indexOf( len ) == -1 )
					symbolsLengths.push( len );
			}
			symbolsLengths.sort( Array.DESCENDING + Array.NUMERIC );

			return true;
		} )();


		public function Tokenizer( str : String )
		{
			_typeDB = new TypeDB;

			this.string = str;
			pos = 0;
		}

		public function get precentReady() : Number
		{
			return pos / string.length;
		}

		public function nextToken() : Token
		{
			if ( pos >= string.length )
				return null;


			var c : String = string.charAt( pos );
			var start : uint = pos;
			prevStr = str; //previous token

			if ( isWhitespace( c ) )
			{
				skipWhitespace();
				c = currentChar();
				start = pos;
			}
			
			if ( c == "*" && string.charAt( pos + 1 ) == "*" )
			{
				pos += 2;
				c = currentChar();
				start = pos;
			}

			if ( isNumber( c ) )
			{
				skipToStringEnd();
				str = string.substring( start, pos );
				return new Token( str, Token.NUMBER, pos );
			}

			if ( c == "#" )
			{
				skipUntil( "\n" );
				return new Token( string.substring( start, pos ), Token.COMMENT, pos );
			}
			
			if ( c == "'" && string.substr( pos, 3 ) == "'''" )
			{
				skipUntil( "'''" );
				return new Token( string.substring( start, pos ), Token.COMMENT, pos );
			}

			if ( isLetter( c ) )
			{
				skipToStringEnd();
				
				str = string.substring( start, pos );
				var type : String;
				if ( isKeyword( str ) )
					type = Token.KEYWORD;
				else if ( isKeyword2( str ) )
					type = Token.KEYWORD2;
				else if ( tokens.length && tokens[ tokens.length - 1 ].string == "[" &&
					( str == "Embed" || str == "Event" || str == "SWF" || str == "Bindable" ) )
					type = Token.KEYWORD;
				else if ( prevStr == "def" )
					type = Token.NAMEFUNCTION;
				else if ( prevStr == "class" )
					type = Token.NAMECLASS;
				else
					type = Token.STRING_LITERAL;
				return new Token( str, type, pos );
			}
			else if ( ( str = isSymbol( pos ) ) != null )
			{
				pos += str.length;
				return new Token( str, Token.SYMBOL, pos );
			}
			else if ( c == "\"" )
			{ 
				if( string.length - pos > 2 && string.substr( pos + 1, 2 ) == "\"\"" )
				{
					skipUntil( "\"\"\"" )					
				}
				else
				{
					skipUntilWithEscNL( c )
				}

				return new Token( string.substring( start, pos ), Token.STRING, pos );
			}
			
			else if (  c == "'" )
			{
				skipUntilWithEscNL( c )
				
				return new Token( string.substring( start, pos ), Token.STRING, pos );
			}
			
			//unknown
			return new Token( c, Token.SYMBOL, ++pos );
		}

		private function currentChar() : String
		{
			return string.charAt( pos );
		}

		private function nextChar() : String
		{
			if ( pos >= string.length - 1 )
				return null;
			return string.charAt( pos + 1 );
		}

		private function skipUntil( exit : String ) : void
		{
			pos++;
			var p : int = string.indexOf( exit, pos );
			if ( p == -1 )
				pos = string.length;
			else
				pos = p + exit.length;
		}

		/** Patch from http://www.physicsdev.com/blog/?p=14#comments - thanks */
		/*private function skipUntilWithEsc(exit:String):void
		   {
		   pos++;
		   var c:String;
		   while ((c=string.charAt(pos)) != exit && c) {
		   if (c == "\\") pos++;
		   pos++;
		   }
		   if (c) pos++;
		 }*/

		private function skipUntilWithEscNL( exit : String ) : void
		{
			//this is faster than regexp
			pos++;
			var c : String;
			while ( ( c = string.charAt( pos ) ) != exit && c != "\r" && c )
			{
				if ( c == "\\" )
					pos++;
				pos++;
			}
			if ( c )
				pos++;
		}

		private function skipWhitespace() : void
		{
			var c : String;
			c = currentChar();
			while ( isWhitespace( c ) )
			{
				pos++;
				c = currentChar();
			}
		}

		private function isWhitespace( str : String ) : Boolean
		{
			return str == " " || str == "\n" || str == "\t" || str == "\r";
		}

		private function skipToStringEnd() : void
		{
			var c : String;
			while ( true )
			{
				c = currentChar();
				if ( !( isLetter( c ) || isNumber( c ) ) )
					break;
				pos++;
			}
		}

		private function isNumber( str : String ) : Boolean
		{
			var code : uint = str.charCodeAt( 0 );
			return ( code >= 48 && code <= 57 );
		}

		static public function isLetter( str : String ) : Boolean
		{
			var code : uint = str.charCodeAt( 0 );
			if ( code == 36 || code == 95 )
				return true;
			if ( code >= 64 && code <= 90 ) //@,A-Z
				return true;
			if ( code >= 97 && code <= 122 ) //a-z
				return true;
			return false;
		}

		private function isKeyword( str : String ) : Boolean
		{
			return keywords.getValue( str );
		}

		private function isKeyword2( str : String ) : Boolean
		{
			return keywords2.getValue( str );
		}

		private function isSymbol( pos : uint ) : String
		{
			var len : uint = symbolsLengths.length;
			for ( var i : int = 0; i < len; i++ )
			{
				var s : String = string.substr( pos, symbolsLengths[ i ] );
				if ( symbols.getValue( s ) )
					return s;
			}
			return null;
		}


		private function lengthSort( strA : String, strB : String ) : int
		{
			if ( strA.length < strB.length )
				return 1;
			if ( strA.length > strB.length )
				return -1;
			return 0;
		}

		internal var tokens : Array;
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

		internal var topScope : Field;
		private var _typeDB : TypeDB;

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

				pos = 0;
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
			if ( t.string == "{" )
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
			else if ( tp && ( tp.string == "class" ||
				tp.string == "def" || tp.string == "catch" || tp.string == "get" || tp.string == "set" ||
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
					
					if ( t.string.slice(0, 2) == "__" )
						access = "private";
					else if ( t.string.slice(0, 1) == "_" )
						access = "protected";
					else
						access = "public";
					
					field.access = access;
						
					//all interface methods are public
					if ( scope.fieldType == "interface" )
						field.access = "public";
					//this is so members will have the parent set to the scope
					field.parent = scope;
				}
				if ( _scope && ( tp.string == "class" ) )
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
			else if ( _scope && ( _scope.fieldType == "def" || _scope.fieldType == "catch" || _scope.fieldType == "set" ) )
			{
				if ( tp && tp.string == "(" && t.string != ")" )
					paramsBlock = true;

				if ( paramsBlock )
				{
					if ( !param && t.string != "..." )
					{
						param = new Field( "var", pos, t.string );
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

			return true;
		}

		internal function kill() : void
		{
			tokens = null;
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
	}
}