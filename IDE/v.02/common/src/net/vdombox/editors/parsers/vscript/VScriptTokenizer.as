package net.vdombox.editors.parsers.vscript
{
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.ImportItemVO;
	import net.vdombox.editors.parsers.LanguageVO;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Multiname;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.editors.parsers.base.Tokenizer;
	
	import ro.victordramba.util.HashMap;
	
	
	public class VScriptTokenizer extends Tokenizer
	{
		public var tree : VScriptToken;
		
		private var newLogicBlock : Boolean = false;
		
		private static const keywordsA : Array = [
			"and", "as", "byref", "byval", "call", "case", "cbool", "cbyte", "cdate", "cdbl", "cint", "catch", "class", "clng", "const", "csng", "date", "dim", "do", "each", "else", "elseif", "end", "erase", "error", "exit", "false", "finally", "for", "function", "get", "goto", "if", "in", "is", "let", "loop", "mod", "next", "new", "not", "nothing", "on", "option", "or", "private", "property", "set", "sub", "public", "default", "readonly", "redim",  "select", "set", "string", "sub", "then", "to", "true", "try", "until", "use", "wend", "while", "with", "xor"
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
		
		
		public function VScriptTokenizer( str : String )
		{
			_classDB = new ClassDB;
			
			this.string = str;
			pos = 0;
		}
		
		public function get members():HashMap
		{
			return _members;
		}
		
		public function get precentReady() : Number
		{
			return pos / string.length;
		}
		
		public function nextToken() : VScriptToken
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
				str = "\r";
				return new VScriptToken( string.substring( start, pos ), Token.ENDLINE, pos );
			}
			
			if ( isNumber( c ) )
			{
				skipToStringEnd();
				str = string.substring( start, pos );
				return new VScriptToken( str, Token.NUMBER, pos );
			}
			
			if ( c == "'" || string.substr( pos, 3 ).toLowerCase() == "rem" )
			{
				skipUntilEnd();
				return new VScriptToken( string.substring( start, pos ), Token.COMMENT, pos );
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
				else if ( prevStr && prevStr.toLowerCase() == "function" )
					type = Token.NAMEFUNCTION;
				else if ( prevStr && prevStr.toLowerCase() == "class" )
					type = Token.NAMECLASS;
				else
					type = Token.STRING_LITERAL;
				return new VScriptToken( str, type, pos );
			}
			else if ( ( str = isSymbol( pos ) ) != null )
			{
				pos += str.length;
				return new VScriptToken( str, Token.SYMBOL, pos );
			}
			else if ( c == "\"" )
			{ 
				
				skipUntilWithEscNL( c )
				
				return new VScriptToken( string.substring( start, pos ), Token.STRING, pos );
			}
				
			/*else if (  c == "'" )
			{
				skipUntilWithEscNL( c )
				
				return new Token( string.substring( start, pos ), Token.STRING, pos );
			}*/
			
			//unknown
			return new VScriptToken( c, Token.SYMBOL, ++pos );
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
		
		private var t : VScriptToken
		private var tp : VScriptToken;
		private var tp2 : VScriptToken;
		private var tp3 : VScriptToken;
		
		private var currentBlock : VScriptToken;
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
		private var dimZone : Boolean = false;
		private var scope : Field;
		private var isStatic : Boolean = false;
		private var access : String;
		
		internal var topScope : Field;
		private var newBlock : Boolean;
		private var waitParams : Boolean;
		
		private var error : Boolean = false;
		
		public override function runSlice() : Boolean
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
				tree = new VScriptToken( "top", null, 0 );
				tree.children = [];
				
				currentBlock = tree;
				
				//top scope
				topScope = scope = new Field( "top", 0, "top" );
				scope.children = [];
				
				pos = 0;
				defParamValue = null;
				paramsBlock = false;
				
				imports = new Array();
				imports.push( new HashMap() );
				scope.imports = imports[0];
				currentBlock.scope = scope;
				
				_members = new HashMap();
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
			var tp2String : String = tp2 ? tp2.string.toLowerCase() : "";
			
			
			if ( ( tpString == "end" || tString == "next" || tString == "wend" || tString == "loop" ) && tp.type != Token.COMMENT )
			{
				closeBlock( tString );
			}
			
			if ( importZone )
			{
				t.importZone = true;
				
				importFrom = tString;
				
				if ( !importFrom || importFrom == "" )
					importFrom = tString;
				
				t.importFrom = importFrom;
				
				var systemName : String = tString;
				
				for each ( var name : AutoCompleteItemVO in HashLibraryArray.getImportToLibraty( importFrom, LanguageVO.vscript ) )
				{
					imports[ imports.length - 1 ].setValue( name.value.toLowerCase(), new ImportItemVO( name.value, name.value, importFrom ) );
				}
				
				position = t.pos + t.string.length;
				while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
					position++;
				
				if ( string.charAt( position ) == '\r' || string.charAt( position ) == '\n' )
				{
					importZone = false;
				}
				
			}
			else if ( t && tString == "use" )
			{
				importZone = true;
				t.fromZone = true;
				importFrom = "";
			}
			else if ( tp && tpString == "new" && tp3)
			{
				var f : Field = scope.getLastRecursionField( tp3.string.toLowerCase() );
				if ( f )
					f.className = t.string;
			}
			else if ( dimZone )
			{
				if ( t.type == Token.STRING_LITERAL )
				{
					field = new Field( "var", t.pos, t.string );
					
					if ( !scope.members.hasKey( tString ) )
					{
						scope.members.setValue( tString, field );
						_members.setValue( t.string, field );
					}
					
					access = "public";
					field.access = access;
					
					field.parent = scope;
				}
				else if ( t.type == Token.ENDLINE )
				{
					dimZone = false;
				}					
			}
			else if ( tString == "dim" )
			{
				dimZone = true;
			}
				
			else if ( tp && ( tpString == "class" ||
				tpString == "function" || tpString == "sub" ) && ( !tp2 || ( tp2String != "end" && tp2String != "exit" ) ) )
			{
				//for package, merge classes in the existing omonimus package
				if ( tpString == "package" && scope.members.hasKey( tString ) )
					_scope = scope.members.getValue( tString );
				else
				{
					if ( tpString != "class" )
						field = new Field( "def", t.pos, t.string );
					else
						field = new Field( tpString, t.pos, t.string );
					
					if ( tString != "(" ) //anonimus functions are not members
					{
						if ( !scope.members.hasKey( tString ) )
						{
							scope.members.setValue( tString, field );
							_members.setValue( tString, field );
						}
					}

					_scope = field;
					newLogicBlock = true;
					
					if ( isStatic ) //consume "static" declaration
					{
						field.isStatic = true;
						isStatic = false;
					}
					
					access = "public";
					
					field.access = access;
					
					//this is so members will have the parent set to the scope
					field.parent = scope;
				}
				if ( _scope && ( tpString == "class" ) )
				{
					_scope.type = new Multiname( "Class" );
					try
					{
						_classDB.addDefinition( _scope.name, field );
					}
					// failproof for syntax errors
					catch ( e : Error )
					{
					}
				}
			}
				
				//parse function params
			else if ( _scope && ( _scope.fieldType == "def" ) )
			{
				if ( tp && tpString == "(" && tString != ")" )
					paramsBlock = true;
				
				if ( paramsBlock )
				{
					if ( !param && t.string != "..." )
					{
						param = new Field( "var", t.pos, t.string );
						t.scope = _scope;
						_scope.params.setValue( tString, param );
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
			if ( tp2 && tp2String == "for" && tpString == "each" && t.type == Token.STRING_LITERAL  )
			{
				field = new Field( "var", t.pos, t.string );
				
				if ( !scope.members.hasKey( tString ) )
				{
					scope.members.setValue( tString, field );
					_members.setValue( t.string, field );
				}
				
				access = "private";
				field.access = access;
				
				field.parent = scope;
			}
			else if ( tString == "=" && tp.type == Token.STRING_LITERAL )
			{
				parsingVariables( tp, tp2, tokens.length - 2 )
			}
			
			if( newLogicBlock )
			{
				newLogicBlock = false;
				
				_scope.parent = scope;
				_scope.children = [];
				scope.children.push( _scope );
				
				scope = _scope;
				t.scope = scope;
				waitParams = true;
			}
			//var tp2String : String = tp2 ? tp2.string.toLowerCase() : "";
			//new block
			if ( checkNewBlock( tString, tpString ) )
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
				else if ( tString == "catch" )
				{
					if ( currentBlock.blockType == BlockType.CATCH )
					{
						t.parent = currentBlock.parent;
						createBlock( BlockType.CATCH, tString );
						currentBlock.mainBlockType = BlockType.TRY;
					}
					else if ( currentBlock.blockType == BlockType.TRY )
					{
						t.parent = currentBlock;
						currentBlock = t;
						t.children = [];
						currentBlock.blockType = BlockType.CATCH;
						currentBlock.mainBlockType = BlockType.TRY;
					}
					else
					{
						t.error = true;
						error = true;
					}
				}
				else if ( tString == "finally" )
				{
					if ( currentBlock.blockType == BlockType.CATCH )
					{
						t.parent = currentBlock.parent;
						createBlock( BlockType.FINALLY, tString );
						currentBlock.mainBlockType = BlockType.TRY;
					}
					else if ( currentBlock.blockType == BlockType.TRY )
					{
						t.parent = currentBlock;
						currentBlock = t;
						t.children = [];
						currentBlock.blockType = BlockType.FINALLY;
						currentBlock.mainBlockType = BlockType.TRY;
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
					
					if ( tString == "if" || ( tString == "then" && VScriptToken( currentBlock.parent ).blockType == BlockType.IF) )
					{
						currentBlock.blockType = BlockType.IF;
						currentBlock.mainBlockType = BlockType.IF;
					}
					else if ( tString == "each" && VScriptToken( currentBlock.parent ).blockType == BlockType.FOR)
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
					else if ( tString == "class" )
					{
						currentBlock.blockType = BlockType.CLASS;
						currentBlock.mainBlockType = BlockType.CLASS;
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
					else if ( tString == "try" )
					{
						currentBlock.blockType = BlockType.TRY;
						currentBlock.mainBlockType = BlockType.TRY;
					}
					
				}
				
				imports.push( imports[ imports.length - 1 ].clone() );
				scope.imports = imports[ imports.length - 1 ];
				currentBlock.scope = scope;
				
				t.scope = scope;
			}
			
			if ( newBlock && ( tString == "then" ) )
			{
				t.createConstruction = true;
			}
			
			if ( t.type == Token.ENDLINE && newBlock )
			{
				newBlock = false;
			}
			
			if ( t.type == Token.ENDLINE && waitParams )
			{
				waitParams = false;
				_scope = null;
			}
			
			if ( newBlock )
			{
				if ( currentBlock.blockType != BlockType.IF && currentBlock.blockType != BlockType.ELSE )
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
		
		private function parsingVariables( tp : VScriptToken, tp2 : VScriptToken, currentPos : int ) : void
		{
			var prevToken : VScriptToken = tp2;
			var curToken : VScriptToken = tp;
			
			if ( !tp2 || ( tp2 && tp2.string != "." ) && tp.string != "this" )
			{
				var curStr : String = curToken.string.toLowerCase()
				field = new Field( "var", curToken.pos, curToken.string );
				
				access = "public";
				
				field.access = access;
				
				field.parent = scope;
				
				if ( !scope.members.hasKey( curStr ) && field.name != scope.name )
				{
					scope.members.setValue( curStr, field );
					_members.setValue( curStr, field );
				}
				
				currentPos -= 2;
				
				if ( prevToken && prevToken.string == "," )
					parsingVariables( tokens[ currentPos ], tokens[ currentPos - 1 ], currentPos );
			}
			else
			{
				while ( prevToken && prevToken.string == "." )
				{
					currentPos -= 2;
					prevToken = tokens[currentPos - 1];
				}
				curToken = tokens[currentPos];
				
				var field : Field;
				
				curStr = curToken.string.toLowerCase();
				
				if ( scope.members.hasKey( curStr ) )
				{
					field = scope.members.getValue( curStr );
				} 
				else 
				{
					field = new Field( "var", curToken.pos, curToken.string );
					
					access = "public";
					
					field.access = access;
					
					field.parent = scope;
					
					if ( findClassParent( scope ) )
					{
						var scp : Field = findClassParent( scope );
						if ( !scp.members.hasKey( tp.string.toLowerCase() ) )
						{
							field = scp;
						}
					}
					else if ( !scope.members.hasKey( tp.string.toLowerCase() ) )
					{
						scope.members.setValue( curStr, field );
					}
				}
				var tField : Field = field;
				
				while ( currentPos <= tokens.length - 4 )
				{
					currentPos += 2;
					curToken = tokens[currentPos];
					curStr = curToken.string.toLowerCase();
					var tField2 : Field; 
					
					if ( tField.members.hasKey( curStr ) )
					{
						tField2 = tField.members.getValue( curStr );
					}
					else 
					{
						tField2 = new Field( "var", curToken.pos, curToken.string );
						
						access = "public";
						
						tField2.access = access;
						tField2.parent = tField;
						
						if ( !tField.members.hasKey( curStr ) )
							tField.members.setValue( curStr, tField2 );
					}
					
					tField = tField2;
				}
				
				currentPos -= 2;
				
				if ( prevToken && prevToken.string == "," )
					parsingVariables( tokens[ currentPos ], tokens[ currentPos - 1 ], currentPos );
			}
		}
		
		private function findClassParent( scp : Field ):Field
		{
			for ( var _scp : Field = scp; _scp && _scp.fieldType != "class"; _scp = _scp.parent )
			{
				
			}
			return _scp;
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
						
						currentBlock = currentBlock.parent as VScriptToken;
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
					else
						setError()
					
					break;
				}
					
				case "elseif":
				{
					if ( currentBlock.blockType == BlockType.IF || currentBlock.blockType == BlockType.ELSE || currentBlock.blockType == BlockType.ELSEIF )
						currentBlock.blockClosed = true;
					else
						setError()
					
					break;
				}
					
				case "select":
				{
					if ( currentBlock.blockType == BlockType.CASE || currentBlock.blockType == BlockType.SELECT )
					{
						currentBlock.blockClosed = true;
						
						currentBlock = currentBlock.parent as VScriptToken;
						imports.pop();
						
						currentBlock.blockClosed = true;
					}
					else
					{
						setError()
					}
					
					
					break;
				}
					
					
				case "try":
				{
					if ( currentBlock.blockType == BlockType.TRY || currentBlock.blockType == BlockType.CATCH || currentBlock.blockType == BlockType.FINALLY )
					{
						currentBlock.blockClosed = true;
						
						if ( currentBlock.blockType == BlockType.TRY )
							break;
						
						currentBlock = currentBlock.parent as VScriptToken;
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
						
						currentBlock = currentBlock.parent as VScriptToken;
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
					{
						currentBlock.blockClosed = true;
						scope = scope.parent;
					}
					else
						setError()
					
					break;
				}
					
				case "function":
				{
					if ( currentBlock.blockType == BlockType.FUNCTION )
					{
						currentBlock.blockClosed = true;
						scope = scope.parent;
					}
					else
						setError()
					
					break;
				}
					
				case "class":
				{
					if ( currentBlock.blockType == BlockType.CLASS )
					{
						currentBlock.blockClosed = true;
						scope = scope.parent;
					}
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
			
			currentBlock = currentBlock.parent as VScriptToken;
			imports.pop();
		}
		
		private function checkNewBlock(value : String, prevValue : String) : Boolean
		{
			if ( value == "elseif" ||  (( value == "for"|| value == "do" ) && prevValue != "exit" ) || ( value == "then" && currentBlock && currentBlock.blockType == BlockType.IF ) )
				return true;
			
			if ( ( value == "if" || value == "select" || value == "class" || value == "try" || (( value == "function" || value == "sub") && prevValue != "exit" ) ) && prevValue != "end"  )
				return true;
			
			if ( value == "else" && prevValue != "case" )
				return true;
				
			if ( value == "case" || value == "catch" || value == "finally" )
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
		
		public override function tokenByPos( pos : uint ) : Token
		{
			if ( !tokens /*|| tokens.length < 3 */)
				return null;
			//TODO: binary search
			for ( var i : int = tokens.length - 1; i >= 0; i-- )
				if ( tokens[ i ] && pos >= tokens[ i ].pos )
					return VScriptToken.map[ tokens[ i ].id ];
			return null;
		}
		
		public function token2prevByPos( pos : uint ) : Token
		{
			if ( !tokens || tokens.length < 3 )
				return null;
			//TODO: binary search
			for ( var i : int = tokens.length - 1; i >= 2; i-- )
				if ( tokens[ i ] && pos >= tokens[ i ].pos )
				{
					if ( tokens[ i ] && pos == tokens[ i ].pos )
						return VScriptToken.map[ tokens[ i - 2].id ];
					else
						return VScriptToken.map[ tokens[ i - 1].id ];
				}
					
			return null;
		}
	}
}