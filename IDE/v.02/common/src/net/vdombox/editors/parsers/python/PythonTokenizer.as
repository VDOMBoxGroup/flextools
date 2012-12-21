package net.vdombox.editors.parsers.python
{

	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.ImportItemVO;
	import net.vdombox.editors.parsers.base.BlockPosition;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.base.Multiname;
	import net.vdombox.editors.parsers.base.Token;
	import net.vdombox.editors.parsers.base.Tokenizer;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	
	import ro.victordramba.util.HashMap;


	public class PythonTokenizer extends Tokenizer
	{
		public var tree : PythonToken;

		private static const keywordsA : Array = [
			"and", "as", "del", "for", "is", "raise", "assert", "elif", "from", "lambda", "return", "break", "else", "global", "None", "not", "try", "True", "False", "except", "if", "or", "while", "continue", "exec", "import", "pass", "yield", "finally", "in", "print"
		];

		private static const keywords2A : Array = [
			"self" 
		];
		
		private static const keywords3A : Array = [
			"class", "def"
		];

		private static const symbolsA : Array = [
			"+", "-", "/", "*", "=", "<", ">", "%", "!", "&", ";", "?", "`", ":", ",", "." ];

		private static const keywords : HashMap = new HashMap();
		private static const keywords2 : HashMap = new HashMap();
		private static const keywords3 : HashMap = new HashMap();
		private static const symbols : HashMap = new HashMap();
		private static const symbolsLengths : Array = [];
		private var blockPosition : BlockPosition;

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
			
			for each ( s in keywords3A )
			{
				keywords3.setValue( s, true );
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


		public function PythonTokenizer( str : String )
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

		public function nextToken() : PythonToken
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
				return new PythonToken( string.substring( start, pos ), Token.ENDLINE, pos );
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
				return new PythonToken( str, Token.NUMBER, pos );
			}

			if ( c == "#" )
			{
				skipUntilEnd();
				return new PythonToken( string.substring( start, pos ), Token.COMMENT, pos );
			}
			
			if ( c == "'" && string.substr( pos, 3 ) == "'''" || c == '"' && string.substr( pos, 3 ) == '"""')
			{
				if ( string.substr( pos, 3 ) == "'''" )
					skipUntil( "'''" );
				else
					skipUntil( '"""' );
				
				return new PythonToken( string.substring( start, pos ), Token.COMMENT, pos );
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
				else if ( isKeyword3( str ) )
					type = Token.KEYWORD3;
				else if ( tokens.length && tokens[ tokens.length - 1 ].string == "[" &&
					( str == "Embed" || str == "Event" || str == "SWF" || str == "Bindable" ) )
					type = Token.KEYWORD;
				else if ( prevStr == "def" )
					type = Token.NAMEFUNCTION;
				else if ( prevStr == "class" )
					type = Token.NAMECLASS;
				else
					type = Token.STRING_LITERAL;
				return new PythonToken( str, type, pos );
			}
			else if ( ( str = isSymbol( pos ) ) != null )
			{
				pos += str.length;
				return new PythonToken( str, Token.SYMBOL, pos );
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

				return new PythonToken( string.substring( start, pos ), Token.STRING, pos );
			}
			
			else if (  c == "'" )
			{
				skipUntilWithEscNL( c )
				
				return new PythonToken( string.substring( start, pos ), Token.STRING, pos );
			}
			
			//unknown
			return new PythonToken( c, Token.SYMBOL, ++pos );
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
				{
					pos = string.length;
					return;
				}
			}
			
			pos = p;
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
			return keywords.getValue( str );
		}

		private function isKeyword2( str : String ) : Boolean
		{
			return keywords2.getValue( str );
		}
		
		private function isKeyword3( str : String ) : Boolean
		{
			return keywords3.getValue( str );
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

		private var currentBlock : PythonToken;
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
		private var descriptionZone : Boolean = false;
		private var endDescriptionZone : Boolean = false;

		internal var topScope : Field;
		
		private var newBlock : Boolean;
		
		private var tabOtstyp : int = 0;
		private var spaceOtstyp : int = 0;

		public override function runSlice() : Boolean
		{
			//init (first run)
			if ( !tokens )
			{
				tokens = [];
				tree = new PythonToken( "top", null, 0 );
				tree.children = [];
				tree.otstyp = { tabs : 0, spaces : 0 };
				
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

			var t : PythonToken = nextToken();
			if ( !t )
			{
				for each ( var block : BlockPosition in stackBlocks )
				{
					block.end = tokens[ tokens.length - 1].pos;
					if ( !blocks )
						blocks = new Array();
					
					blocks.push( block );
				}
				
				return false;
			}
			
			var tString : String = t.string;
			tokens.push( t );
			
			tabOtstyp = 0;
			spaceOtstyp = 0;
			newBlock = false;
			
			var position : int = pos - 1;
			
			if ( t.type == Token.ENDLINE )
			{
				if ( currentBlock && tokens.length >= 2 /*&& tokens[ tokens.length - 2 ].type != Token.COMMENT */&& string.charAt( position + 1 ) != "\r" && string.charAt( position + 1 ) != "\n" )
				{
					do
					{
						position++;
						
						while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
						{
							if ( string.charAt( position ) == '\t' )
								tabOtstyp++;
							else
								spaceOtstyp++;
							position++;
						}
					}
					while ( string.charAt( position ) == '\r' || string.charAt( position ) == '\n' );
						
					if ( ( currentBlock.otstyp.tabs > tabOtstyp || currentBlock.otstyp.spaces > spaceOtstyp ||
						( stackBlocks && stackBlocks.length > 0 && (stackBlocks[stackBlocks.length-1].otstyp.tabs > tabOtstyp || stackBlocks[stackBlocks.length-1].otstyp.spaces > spaceOtstyp))) && string.charAt( position ) != '#'
					&& string.substr( position, 3 ) != "'''" )
					{
						var index : int;
						
						while ( currentBlock.otstyp.tabs > tabOtstyp || currentBlock.otstyp.spaces > spaceOtstyp ||
							stackBlocks.length > 0 && (stackBlocks[stackBlocks.length - 1].otstyp.tabs > tabOtstyp || stackBlocks[stackBlocks.length - 1].otstyp.spaces > spaceOtstyp))
						{			
							if ( currentBlock.otstyp.tabs > tabOtstyp || currentBlock.otstyp.spaces > spaceOtstyp )
							{
								scope = scope.parent;
								currentBlock = currentBlock.parent as PythonToken;
								imports.pop();
							}
							
							index = tokens.length - 1;
							
							while( tokens[index].type == Token.ENDLINE || tokens[index].type == Token.COMMENT )
								index--;
							
							if ( stackBlocks.length > 0 )
							{
								stackBlocks[stackBlocks.length - 1].end = tokens[index].pos;
								
								if ( !blocks )
									blocks = new Array();
								
								blocks.push( stackBlocks.pop() );
							}
						}
					}
				}
			}
			
			t.parent = currentBlock;
			currentBlock.children.push( t );
			
			if ( !descriptionZone && endDescriptionZone )
			{
				endDescriptionZone = false;
				if ( t.type == Token.COMMENT )
				{
					if ( tString.substr( 0, 1 ) != "#" )
					{
						scope.description = tString.substring( 3, tString.length - 3 );
					}
				}
			}
			
			t.scope = scope;

			var tokensLength : uint = tokens.length - 1;
			
			var tp : PythonToken = tokens[ tokensLength - 1 ];
			var tpString : String = tp ? tp.string : "";
			
			var tp2 : PythonToken = tokens[ tokensLength - 2 ];
			var tp2String : String = tp2 ? tp2.string : "";
			
			var tp3 : PythonToken = tokens[ tokensLength - 3 ];
			var tp3String : String = tp3 ? tp3.string : "";

			if ( importZone )
			{
				t.importZone = true;
				
				if ( !importFrom || importFrom == "" )
					importFrom = tString;
				
				t.importFrom = importFrom;
				
				var systemName : String = t.string;
				
				if ( tpString == "as" )
				{
					imports[ imports.length - 1 ].removeValue( tpString );
					imports[ imports.length - 1 ].removeValue( tp2String );
					systemName = tp2String;
				}
				
				if ( t.type != Token.SYMBOL )
				{
					imports[ imports.length - 1 ].setValue( tString, new ImportItemVO( tString, systemName, importFrom ) );
					
					position = t.pos + tString.length;
					while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
						position++;
					
					if ( string.charAt( position ) == '\r' || string.charAt( position ) == '\n' )
					{
						importZone = false;
						importFrom = "";
					}
				}
				else if ( tString == "*" )
				{
					if ( actionVO is LibraryVO )
						addPrevImport( actionVO.name );
					
					for each ( var name : AutoCompleteItemVO in HashLibraryArray.getImportToLibraty( importFrom, "python", prevImport ) )
					{
						imports[ imports.length - 1 ].setValue( name.value, new ImportItemVO( name.value, name.value, importFrom ) );
					}
					
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
			else if ( tString == "from" )
			{
				fromZone = true;
				t.fromZone = true;
				importFrom = "";
			}
			else if ( tString == "import" )
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
			else if ( tString == "@staticmethod" )
			{
				isStatic = true;
			}
			else if ( tString == "@classmethod" )
			{
				isClassMethod = true;
			}
			else if ( tString == "get" || tString == "set" )
			{
				//do nothing
			}
			
			else if ( tpString == "class" || tpString == "def" || tpString == "const" )
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
					{
						if ( !scope.members.hasKey( tString ) )
						{
							scope.members.setValue( tString, field );
							_members.setValue( tString, field );
						}
					}
					
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
					
					if ( tString.slice(0, 2) == "__" )
						access = "private";
					else if ( tString.slice(0, 1) == "_" )
						access = "protected";
					else
						access = "public";
					
					field.access = access;
						
					//all interface methods are public
					if ( scope.fieldType == "interface" )
						field.access = "public";
					//this is so members will have the parent set to the scope
					field.parent = scope;
					
					descriptionZone = true;
				}
				if ( _scope && ( tpString == "class" ) )
				{
					_scope.type = new Multiname( "Class" );
					try
					{
						_classDB.addDefinition( scope.name, field );
					}
					// failproof for syntax errors
					catch ( e : Error )
					{
					}
				}
				//add current package to imports
				if ( tpString == "package" )
					imports.setValue( tString + ".*", tString + ".*" );
			}

			//parse function params
			else if ( _scope && ( _scope.fieldType == "def" || _scope.fieldType == "class" ) )
			{
				if ( tpString == "(" && tString != ")" )
					paramsBlock = true;

				if ( paramsBlock )
				{
					if ( !param && tString != "..." )
					{
						param = new Field( "var", t.pos, tString );
						t.scope = _scope;
						_scope.params.setValue( param.name, param );
						if ( tp.string == "..." )
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
			if ( tpString == "for" && t.type == Token.STRING_LITERAL  )
			{
				field = new Field( "var", t.pos, tString );
				
				if ( !scope.members.hasKey( tString ) )
				{
					scope.members.setValue( tString, field );
					_members.setValue( tString, field );
				}
				
				access = "private";
				field.access = access;
				
				field.parent = scope;
			}
			else if ( tString == "=" && tp.type == Token.STRING_LITERAL && !paramsBlock )
			{
				parsingVariables( tp, tp2, tokens.length - 2 )
			}

			

			if ( field && tp3 && tpString == ":" )
			{
				if ( tp3String == "var" || tp3String == "const" || tp2String == ")" )
				{
					if ( field.fieldType != "set" )
					{
						field.type = new Multiname( tString, imports[ imports.length - 1 ] );
					}
					field = null;
				}
			}
			
			if ( tString == "def" || tString == "class" || tString == "if" || tString == "else" || tString == "for" || tString == "elif" ||
				tString == "try" || tString == "except" || tString == "while")
				blockPosition = new BlockPosition( t.pos );

			if ( ( tpString == ":" && t.type == Token.ENDLINE )
					|| ( tp2String == ":" && tp.type == Token.COMMENT && t.type == Token.ENDLINE ) )
			{	
				if ( blockPosition )
				{
					getCurrentOtstyp();
					
					blockPosition.otstyp = { tabs : countTabToCurrentBlock, spaces : countSpaceToCurrentBlock };
					
					if ( !stackBlocks )
						stackBlocks = new Array();
					
					stackBlocks.push( blockPosition );
				}
				
				if ( _scope )
				{
					descriptionZone = false;
					endDescriptionZone = true;
					
					currentBlock = t;
					t.children = [];	
					
					getCurrentOtstyp();
					
					currentBlock.otstyp = { tabs : countTabToCurrentBlock, spaces : countSpaceToCurrentBlock };
					
					imports.push( imports[ imports.length - 1 ].clone() );
					
					scope.imports = imports[ imports.length - 1 ];
					currentBlock.scope = scope;
					
					/*if ( !_scope )
						_scope = new Field( scope.fieldType, t.pos, "none" );*/
					
					_scope.imports = imports[ imports.length - 1 ];
					_scope.parent = scope;
					_scope.children = [];
					scope.children.push( _scope );
					
					scope = _scope;
					t.scope = scope;
					
					//info += pos + ")" + scope.parent.name + "->" + scope.name+"\n";
					_scope = null;
				}
			}
			
			if ( t.type == Token.ENDLINE )
				blockPosition = null;
			
			return true;
		}
		
		private function getCurrentOtstyp() : void
		{
			var position : int = pos;
			do
			{
				countSpaceToCurrentBlock = 0;
				countTabToCurrentBlock = 0;
				
				while( string.charAt( position ) == '\n' || string.charAt( position ) == '\r' )
					position++;
				
				while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
				{
					if ( string.charAt( position ) == '\t' )
						countTabToCurrentBlock++;
					else
						countSpaceToCurrentBlock++;
					position++;
				}
			}
			while ( string.charAt( position ) == '\n' || string.charAt( position ) == '\r'  )
		}
		
		private function parsingVariables( tp : PythonToken, tp2 : PythonToken, currentPos : int ) : void
		{
			var prevToken : PythonToken = tp2;
			var curToken : PythonToken = tp;
			
			if ( !tp2 || ( tp2 && tp2.string != "." ) && tp.string != "self" )
			{
				field = new Field( "var", curToken.pos, curToken.string );
				
				if ( !scope.members.hasKey( curToken.string ) )
				{
					scope.members.setValue( curToken.string, field );
					_members.setValue( curToken.string, field );
				}
				
				if ( curToken.string.slice(0, 2) == "__" )
					access = "private";
				else if ( curToken.string.slice(0, 1) == "_" )
					access = "protected";
				else
					access = "public";
				
				field.access = access;
				
				field.parent = scope;
				
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
				
				if ( scope.members.hasKey( curToken.string ) )
				{
					field = scope.members.getValue( curToken.string );
				} 
				else 
				{
					field = new Field( "var", curToken.pos, curToken.string );
					if ( curToken.string.slice(0, 2) == "__" )
						access = "private";
					else if ( curToken.string.slice(0, 1) == "_" )
						access = "protected";
					else
						access = "public";
					
					field.access = access;
					
					field.parent = scope;
					
					if ( findClassParent( scope ) )
					{
						var scp : Field = findClassParent( scope );
						if ( !scp.members.hasKey( tp.string ) )
						{
							field = scp;
						}
					}
					else if ( !scope.members.hasKey( tp.string ) )
					{
						scope.members.setValue( curToken.string, field );
					}
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
						tField2 = new Field( "var", curToken.pos, curToken.string );
						if ( curToken.string.slice(0, 2) == "__" )
							access = "private";
						else if ( curToken.string.slice(0, 1) == "_" )
							access = "protected";
						else
							access = "public";
						
						tField2.access = access;
						tField2.parent = tField;
						
						if ( !tField.members.hasKey( curToken.string ) )
							tField.members.setValue( curToken.string, tField2 );
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
					return PythonToken.map[ tokens[ i ].id ];
			return null;
		}
	}
}