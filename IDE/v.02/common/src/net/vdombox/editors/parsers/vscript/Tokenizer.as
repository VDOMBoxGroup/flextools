package net.vdombox.editors.parsers.vscript
{
	import net.vdombox.editors.parsers.Multiname;
	
	import ro.victordramba.util.HashMap;
	
	
	public class Tokenizer
	{
		public var tree : Token;
		
		private var string : String;
		private var pos : uint;
		private var str : String;
		private var prevStr : String;
		
		private static const keywordsA : Array = [
			"and", "as", "byref", "byval", "call", "case", "cbool", "cbyte", "cdate", "cdbl", "cint", "class", "clng", "const", "csng", "cstr", "date", "dim", "do", "each", "else", "elseif", "end", "erase", "error", "exit", "false", "for", "function", "get", "goto", "if", "in", "is", "let", "loop", "mod", "next", "new", "not", "nothing", "on", "option", "or", "private", "property", "set", "sub", "public", "default", "readonly", "redim",  "select", "set", "string", "sub", "then", "to", "true", "wend", "while", "with", "xor"
		];
		
		private static const keywords2A : Array = [
			"this" 
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
			_typeDB = new ClassDB;
			
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
			
			if ( isNorR( c ) )
			{
				pos++;
				return new Token( string.substring( start, pos ), Token.ENDLINE, pos );
			}
			
			if ( isNumber( c ) )
			{
				skipToStringEnd();
				str = string.substring( start, pos );
				return new Token( str, Token.NUMBER, pos );
			}
			
			if ( c == "'" || string.substr( pos, 3 ).toLowerCase() == "rem" )
			{
				skipUntilEnd();
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
				else if ( prevStr && prevStr.toLowerCase() == "function" )
					type = Token.NAMEFUNCTION;
				else if ( prevStr && prevStr.toLowerCase() == "class" )
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
				
				skipUntilWithEscNL( c )
				
				return new Token( string.substring( start, pos ), Token.STRING, pos );
			}
				
			/*else if (  c == "'" )
			{
				skipUntilWithEscNL( c )
				
				return new Token( string.substring( start, pos ), Token.STRING, pos );
			}*/
			
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
		
		private function skipUntilEnd() : void
		{
			pos++;
			var p : int = string.indexOf( '\r', pos );
			if ( p == -1 )
			{
				p = string.indexOf( '\n', pos );
				if ( p == -1 )
					pos = string.length;
				else
					pos = p + '\n'.length;
			}
			else
				pos = p + '\r'.length;
		}
		
		private function skipUntilWithEscNL( exit : String ) : void
		{
			//this is faster than regexp
			pos++;
			var c : String;
			while ( ( c = string.charAt( pos ) ) != exit && c != "\r" && c || ( c == "\"" && string.charAt( pos + 1 ) == "\"" ))
			{
				if ( c == "\\" || c == "\"")
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
		
		private function isNorR( str : String ) : Boolean
		{
			return str == "\n" || str == "\r";
		}
		
		private function isWhitespace( str : String ) : Boolean
		{
			return str == " " || str == "\t" ;
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
			return keywords.getValue( str.toLowerCase() );
		}
		
		private function isKeyword2( str : String ) : Boolean
		{
			return keywords2.getValue( str.toLowerCase() );
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
		
		private var t : Token
		private var tp : Token;
		private var tp2 : Token;
		private var tp3 : Token;
		
		internal var tokens : Array;
		private var currentBlock : Token;
		private var countSpaceToCurrentBlock : int;
		private var countTabToCurrentBlock : int;
		private var _scope : Field;
		private var field : Field;
		private var param : Field;
		private var defParamValue : String;
		private var paramsBlock : Boolean;
		private var globalImports : HashMap;
		private var imports : Array;
		private var importZone : Boolean = false;
		private var fromZone : Boolean = false;
		private var importFrom : String;
		private var scope : Field;
		private var isStatic : Boolean = false;
		private var isClassMethod : Boolean = false;
		private var access : String;
		
		internal var topScope : Field;
		private var _typeDB : ClassDB;
		private var newBlock : Boolean;
		
		private var error : Boolean = false;
		
		
		internal function get typeDB() : ClassDB
		{
			return _typeDB;
		}
		
		public function runSlice() : Boolean
		{
			//init (first run)
			if ( !tokens || error)
			{
				if ( error )
				{
					error = false;
					return false;
				}
				tokens = [];
				tree = new Token( "top", null, 0 );
				tree.children = [];
				
				currentBlock = tree;
				
				
				//top scope
				topScope = scope = new Field( "top", 0, "top" );
				
				pos = 0;
				defParamValue = null;
				paramsBlock = false;
				
				imports = new Array();
				imports.push( new HashMap() );
				currentBlock.imports = imports[0];
				currentBlock.scope = scope;
			}
			
			t = nextToken();
			if ( !t )
				return false;
			
			tokens.push( t );
			
			var position : int = pos - 1;
			
			t.parent = currentBlock;

			currentBlock.children.push( t );
			
			t.scope = scope;
			
			var tokensLength : uint = tokens.length - 1;
			tp = tokens[ tokensLength - 1 ];
			tp2 = tokens[ tokensLength - 2 ];
			tp3 = tokens[ tokensLength - 3 ];
			
			var tString : String = t.string.toLowerCase();
			var tpString : String = tp ? tp.string.toLowerCase() : "";
			
			
			if ( ( tpString == "end" || tString == "next" || tString == "wend" || tString == "loop" ) && tp.type != Token.COMMENT )
			{
				closeBlock( tString );
			}
			
			if ( importZone )
			{
				t.importZone = true;
				
				if ( !importFrom || importFrom == "" )
					importFrom = tString;
				
				t.importFrom = importFrom;
				
				var systemName : String = tString;
				
				if ( tp.string == "as" )
				{
					imports[ imports.length - 1 ].removeValue( tp.string );
					imports[ imports.length - 1 ].removeValue( tp2.string );
					systemName = tp2.string;
				}
				
				if ( t.type != Token.SYMBOL )
				{
					imports[ imports.length - 1 ].setValue( tString, { name : tString, systemName : systemName, source : importFrom } );
					
					position = t.pos + tString.length;
					while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
						position++;
					
					if ( string.charAt( position ) == '\r' || string.charAt( position ) == '\n' )
					{
						importZone = false;
						importFrom = "";
					}
				}
				
			}
			else if ( t && tString == "from" )
			{
				fromZone = true;
				t.fromZone = true;
				importFrom = "";
			}
			else if ( t && tString == "import" )
			{
				fromZone = false;
				importZone = true;
				t.importZone = true;
				t.importFrom = importFrom;
			}
			else if ( fromZone )
			{
				t.fromZone = true;
				importFrom += tString;
			}
			/*else if ( t.string == "@staticmethod" )
			{
				isStatic = true;
			}
			else if ( t.string == "@classmethod" )
			{
				isClassMethod = true;
			}*/
			else if ( tString == "get" || tString == "set" )
			{
				//do nothing
			}
				
			else if ( tp && ( tpString == "class" ||
				tpString == "function" ||
				tpString == "const" ) )
			{
				//for package, merge classes in the existing omonimus package
				if ( tpString == "package" && scope.members.hasKey( tString ) )
					_scope = scope.members.getValue( tString );
				else
				{
					//debug("field-"+tp.string);
					//TODO if is "set" make it "*set"
					field = new Field( tpString, t.pos, tString );
					if ( tString != "(" ) //anonimus functions are not members
						scope.selfMembers.setValue( tString, field );
					if ( tpString != "var" && tpString != "const" )
						_scope = field;
					
					if ( isStatic ) //consume "static" declaration
					{
						field.isStatic = true;
						isStatic = false;
					}
					
					if ( isClassMethod ) 
					{
						field.isClassMethod = true;
						isClassMethod = false;
					}
					
					/*if ( t.string.slice(0, 2) == "__" )
						access = "private";
					else if ( t.string.slice(0, 1) == "_" )
						access = "protected";
					else*/
						access = "public";
					
					field.access = access;
					
					//all interface methods are public
					if ( scope.fieldType == "interface" )
						field.access = "public";
					//this is so members will have the parent set to the scope
					field.parent = scope;
				}
				if ( _scope && ( tpString == "class" ) )
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
					imports.setValue( tString + ".*", tString + ".*" );
			}
			else if ( checkNewBlock( tString, tpString ) )
			{
				_scope = new Field( tpString, t.pos, tString );
			}
			
			if ( tString == ";" )
			{
				field = null;
				_scope = null;
				isStatic = false;
			}
				
				//parse function params
			else if ( _scope && ( _scope.fieldType == "def" || _scope.fieldType == "catch" || _scope.fieldType == "set" ) )
			{
				if ( tp && tpString == "(" && tString != ")" )
					paramsBlock = true;
				
				if ( paramsBlock )
				{
					if ( !param && t.string != "..." )
					{
						param = new Field( "var", pos, tString );
						t.scope = _scope;
						_scope.params.setValue( param.name, param );
						if ( tpString == "..." )
						{
							_scope.hasRestParams = true;
							param.type = new Multiname( "Array" );
						}
					}
					else if ( tpString == ":" )
					{
						if ( _scope.fieldType == "set" )
						{
							_scope.type = new Multiname( tString, imports[ imports.length - 1 ] );
						}
						else
							param.type = new Multiname( tString, imports[ imports.length - 1 ] );
					}
						
					else if ( tString == "=" )
						defParamValue = "";
						
					else if ( tString == "," || tString == ")" )
					{
						if ( tString == ")" )
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
			else if ( tString == "=" && tp.type == Token.STRING_LITERAL )
			{
				if ( tp2 && tp2.string != "." )
				{
					field = new Field( "var", t.pos, tpString );
					
					if ( currentBlock.scope.fieldType == "class" || currentBlock.scope.fieldType == "top")
						currentBlock.scope.selfMembers.setValue( tpString, field );
					else
						scope.members.setValue( tpString, field );
					
					/*if ( tp.string.slice(0, 2) == "__" )
						access = "private";
					else if ( t.string.slice(0, 1) == "_" )
						access = "protected";
					else*/
						access = "public";
					
					field.access = access;
					
					field.parent = scope;
				}
				else
				{
					var currentPos : int = tokens.length - 2;
					var prevToken : Token = tokens[currentPos - 1];
					while ( prevToken && prevToken.string == "." )
					{
						currentPos -= 2;
						prevToken = tokens[currentPos - 1];
					}
					var curToken : Token = tokens[currentPos];
					
					if ( scope.members.hasKey( curToken.string ) )
					{
						field = scope.members.getValue( curToken.string );
					}
					else 
					{
						field = new Field( "var", t.pos, curToken.string );
						/*if ( curToken.string.slice(0, 2) == "__" )
							access = "private";
						else if ( curToken.string.slice(0, 1) == "_" )
							access = "protected";
						else*/
							access = "public";
						
						field.access = access;
						
						if ( currentBlock.scope.fieldType == "class" || currentBlock.scope.fieldType == "top")
							currentBlock.scope.selfMembers.setValue( curToken.string, field );
						else
							scope.members.setValue( curToken.string, field );
					}
					var tField : Field = field;
					
					while ( currentPos <= tokens.length - 4 )
					{
						currentPos += 2;
						curToken = tokens[currentPos]
						var tField2 : Field;
						
						if ( tField.members.hasKey( curToken.string ) )
						{
							tField2 = tField.members.getValue( curToken.string );
						}
						else 
						{
							tField2 = new Field( "var", t.pos, curToken.string );
							/*if ( curToken.string.slice(0, 2) == "__" )
								access = "private";
							else if ( curToken.string.slice(0, 1) == "_" )
								access = "protected";
							else*/
								access = "public";
							
							tField2.access = access;
							tField.members.setValue( curToken.string, tField2 );
						}
						
						tField = tField2;
					}
					
					
					
					/*if ( tp.string.slice(0, 2) == "__" )
						access = "private";
					else if ( t.string.slice(0, 1) == "_" )
						access = "protected";
					else*/
						access = "public";
					
					field.access = access;
					
					field.parent = scope;
				}
				
			}
			
			
			
			if ( field && tp3 && tpString == ":" )
			{
				if ( tp3.string == "var" || tp3.string == "const" || tp2.string == ")" )
				{
					if ( field.fieldType != "set" )
					{
						field.type = new Multiname( tString, imports[ imports.length - 1 ] );
					}
					field = null;
				}
			}
			
			
			//new block
			if ( checkNewBlock( tString, tpString ) && _scope )
			{	
				newBlock = true;
				
				if ( tString == "elseif" || tString == "else"  )
				{
					t.parent = currentBlock.parent;
					if ( currentBlock.blockType == BlockType.IF || currentBlock.blockType == BlockType.ELSEIF )
					{
						createBlock( tString, tString );
						currentBlock.mainBlockType = BlockType.IF;
					}
					else
					{
						t.error = true;
						error = true;
					}
				}
				else if ( tString == "case" && tpString != "select" )
				{
					t.parent = currentBlock.parent;
					if ( currentBlock.blockType == BlockType.CASE || currentBlock.blockType == BlockType.SELECT )
					{
						createBlock( BlockType.CASE, tString );
						currentBlock.mainBlockType = BlockType.SELECT;
					}
					else
					{
						t.error = true;
						error = true;
					}
				}
				else 
				{
					currentBlock = t;
					t.children = [];
					
					if ( tString == "if" || ( tString == "then" && currentBlock.parent.blockType == BlockType.IF) )
					{
						currentBlock.blockType = BlockType.IF;
						currentBlock.mainBlockType = BlockType.IF;
					}
					else if ( tString == "each" && currentBlock.parent.blockType == BlockType.FOR)
					{
						currentBlock.blockType = BlockType.FOREACH;
						currentBlock.mainBlockType = BlockType.FOR;
					}
					else if ( tString == "select" || tString == "case" )
					{
						currentBlock.blockType = BlockType.SELECT;
						currentBlock.mainBlockType = BlockType.SELECT;
					}
					else if ( tString == "sub" )
					{
						currentBlock.blockType = BlockType.SUB;
						currentBlock.mainBlockType = BlockType.SUB;
					}
					else if ( tString == "function" )
					{
						currentBlock.blockType = BlockType.FUNCTION;
						currentBlock.mainBlockType = BlockType.FUNCTION;
					}
					else if ( tString == "for" )
					{
						currentBlock.blockType = BlockType.FOR;
						currentBlock.mainBlockType = BlockType.FOR;
					}
					else if ( tString == "do" )
					{
						currentBlock.blockType = BlockType.DO;
						currentBlock.mainBlockType = BlockType.DO;
					}
					else if ( tString == "while" )
					{
						currentBlock.blockType = BlockType.WHILE;
						currentBlock.mainBlockType = BlockType.WHILE;
					}
					
				}
				
				imports.push( imports[ imports.length - 1 ].clone() );
				currentBlock.imports = imports[ imports.length - 1 ];
				currentBlock.scope = scope;
				_scope.pos = t.pos;
				_scope.parent = scope;
				_scope.members = scope.members;
				scope = _scope;
				t.scope = scope;
				
				_scope = null;
			}
			
			if ( newBlock && ( tString == "then" ) )
			{
				t.createConstruction = true;
			}
			
			if ( t.type == Token.ENDLINE && newBlock )
			{
				newBlock = false;
			}
			
			if ( newBlock )
			{
				if ( currentBlock.blockType != BlockType.IF && currentBlock.blockType != BlockType.ELSE
					&& currentBlock.blockType != BlockType.ELSEIF )
					t.createConstruction = true;
			}
			
			return true;
			
			function createBlock( typeBLock : String, endString : String ) : void
			{
				closeBlock( endString );
				currentBlock = t;
				t.children = [];
				currentBlock.blockType = typeBLock;
			}
		}
		
		private function closeBlock( endString : String ) : void
		{
			switch(endString)
			{
				case "if":
				{
					if ( currentBlock.blockType == BlockType.IF || currentBlock.blockType == BlockType.ELSE || currentBlock.blockType == BlockType.ELSEIF )
					{
						currentBlock.blockClosed = true;
						
						if ( currentBlock.pos == scope.pos )
						{
							scope = scope.parent;
						}
						
						currentBlock = currentBlock.parent;
						imports.pop();
						
						currentBlock.blockClosed = true;
					}
					else
					{
						setError()
					}
						
					
					break;
				}
					
				case "else":
				{
					if ( currentBlock.blockType == BlockType.IF || currentBlock.blockType == BlockType.ELSE || currentBlock.blockType == BlockType.ELSEIF )
						currentBlock.blockClosed = true;
					
					break;
				}
					
				case "elseif":
				{
					if ( currentBlock.blockType == BlockType.IF || currentBlock.blockType == BlockType.ELSE || currentBlock.blockType == BlockType.ELSEIF )
						currentBlock.blockClosed = true;
					
					break;
				}
					
				case "select":
				{
					if ( currentBlock.blockType == BlockType.CASE || currentBlock.blockType == BlockType.SELECT )
					{
						currentBlock.blockClosed = true;
						
						if ( currentBlock.pos == scope.pos )
						{
							scope = scope.parent;
						}
						
						currentBlock = currentBlock.parent;
						imports.pop();
						
						currentBlock.blockClosed = true;
					}
					else
					{
						setError()
					}
					
					
					break;
				}
					
				case "next":
				{					
					if ( currentBlock.blockType == BlockType.FOR || currentBlock.blockType == BlockType.FOREACH )
					{
						currentBlock.blockClosed = true;
						if ( currentBlock.blockType == BlockType.FOR )
							break;
						
						if ( currentBlock.pos == scope.pos )
						{
							scope = scope.parent;
						}
						
						currentBlock = currentBlock.parent;
						imports.pop();
						
						currentBlock.blockClosed = true;
					}
					else
					{
						setError()
					}
					
					break;
				}
					
				case "sub":
				{
					if ( currentBlock.blockType == BlockType.SUB )
						currentBlock.blockClosed = true;
					else
						setError()
					
					break;
				}
					
				case "function":
				{
					if ( currentBlock.blockType == BlockType.FUNCTION )
						currentBlock.blockClosed = true;
					else
						setError()
					
					break;
				}
					
				case "loop":
				{
					if ( currentBlock.blockType == BlockType.DO )
						currentBlock.blockClosed = true;
					else
						setError()
					
					break;
				}
					
				case "wend":
				{
					if ( currentBlock.blockType == BlockType.WHILE )
						currentBlock.blockClosed = true;
					else
						setError()
					
					break;
				}
					
				default:
				{
					break;
				}
			}
			
			if ( currentBlock.pos == scope.pos )
			{
				scope = scope.parent;
			}
			
			currentBlock = currentBlock.parent;
			imports.pop();
		}
		
		private function checkNewBlock(value : String, prevValue : String) : Boolean
		{
			if ( value == "elseif" ||  value == "for" || value == "do" || ( value == "then" && currentBlock && currentBlock.blockType == BlockType.IF ) )
				return true;
			
			if ( ( value == "if" || value == "select" || value == "sub" || value == "function" ) && prevValue != "end"  )
				return true;
			
			if ( value == "else" && prevValue != "case" )
				return true;
				
			if ( value == "case" )
				return true;
					
			if ( value == "while" && prevValue != "do" )
				return true;
			
			if ( value == "each" && prevValue == "for" )
				return true;
				
			return false;
		}
		
		private function setError() : void
		{
			t.error = true;
			tp.error = true;
			error = true;
		}
		
		internal function kill() : void
		{
			tokens = null;
		}
		
		public function tokenByPos( pos : uint ) : Token
		{
			if ( !tokens /*|| tokens.length < 3 */)
				return null;
			//TODO: binary search
			for ( var i : int = tokens.length - 1; i >= 0; i-- )
				if ( tokens[ i ] && pos >= tokens[ i ].pos )
					return Token.map[ tokens[ i ].id ];
			return null;
		}
	}
}