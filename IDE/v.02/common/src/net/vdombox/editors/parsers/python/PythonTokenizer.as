package net.vdombox.editors.parsers.python
{

	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.ClassDB;
	import net.vdombox.editors.parsers.Field;
	import net.vdombox.editors.parsers.Multiname;
	import net.vdombox.editors.parsers.StandardWordsProxy;
	import net.vdombox.editors.parsers.Token;
	import net.vdombox.editors.parsers.Tokenizer;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	
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
			
			if ( c == "'" && string.substr( pos, 3 ) == "'''" )
			{
				skipUntil( "'''" );
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
				currentBlock.imports = imports[0];
				currentBlock.scope = scope;
				
				_members = new HashMap();
			}

			var t : PythonToken = nextToken();
			if ( !t )
				return false;
			
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
						
					if ( ( currentBlock.otstyp.tabs > tabOtstyp || currentBlock.otstyp.spaces > spaceOtstyp ) && string.charAt( position ) != '#'
					&& string.substr( position, 3 ) != "'''" )
					{
						while ( currentBlock.otstyp.tabs > tabOtstyp || currentBlock.otstyp.spaces > spaceOtstyp )
						{						
							scope = scope.parent;
							
							currentBlock = currentBlock.parent as PythonToken;
							imports.pop();
						}
					}
				}
			}
			
			t.parent = currentBlock;
			currentBlock.children.push( t );
			
			
			
			t.scope = scope;

			var tokensLength : uint = tokens.length - 1;
			var tp : PythonToken = tokens[ tokensLength - 1 ];
			var tp2 : PythonToken = tokens[ tokensLength - 2 ];
			var tp3 : PythonToken = tokens[ tokensLength - 3 ];

			if ( importZone )
			{
				t.importZone = true;
				
				if ( !importFrom || importFrom == "" )
					importFrom = t.string;
				
				t.importFrom = importFrom;
				
				var systemName : String = t.string;
				
				if ( tp.string == "as" )
				{
					imports[ imports.length - 1 ].removeValue( tp.string );
					imports[ imports.length - 1 ].removeValue( tp2.string );
					systemName = tp2.string;
				}
				
				if ( t.type != Token.SYMBOL )
				{
					imports[ imports.length - 1 ].setValue( t.string, { name : t.string, systemName : systemName, source : importFrom } );
					
					position = t.pos + t.string.length;
					while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
						position++;
					
					if ( string.charAt( position ) == '\r' || string.charAt( position ) == '\n' )
					{
						importZone = false;
						importFrom = "";
					}
				}
				else if ( t.string == "*" )
				{
					for each ( var name : AutoCompleteItemVO in HashLibraryArray.getImportToLibraty( importFrom, "python" ) )
					{
						imports[ imports.length - 1 ].setValue( name.value, { name : name.value, systemName : name.value, source : importFrom } );
					}
					
					position = t.pos + t.string.length;
					while( string.charAt( position ) == '\t' || string.charAt( position ) == ' ' )
						position++;
					
					if ( string.charAt( position ) == '\r' || string.charAt( position ) == '\n' )
					{
						importZone = false;
						importFrom = "";
					}
				}
					
			}
			else if ( t && t.string == "from" )
			{
				fromZone = true;
				t.fromZone = true;
				importFrom = "";
			}
			else if ( t && t.string == "import" )
			{
				fromZone = false;
				importZone = true;
				t.importZone = true;
				t.importFrom = importFrom;
			}
			else if ( fromZone )
			{
				t.fromZone = true;
				importFrom += t.string;
			}
			else if ( t.string == "@staticmethod" )
			{
				isStatic = true;
			}
			else if ( t.string == "@classmethod" )
			{
				isClassMethod = true;
			}
			else if ( t.string == "get" || t.string == "set" )
			{
				//do nothing
			}
			
			else if ( tp && ( tp.string == "class" ||
				tp.string == "def" ||
				 tp.string == "const" ) )
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
					{
						if ( !scope.members.hasKey( t.string ) )
						{
							scope.members.setValue( t.string, field );
							_members.setValue( t.string, field );
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
						_classDB.addDefinition( scope.name, field );
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
			else if ( _scope && ( _scope.fieldType == "def" ) )
			{
				if ( tp && tp.string == "(" && t.string != ")" )
					paramsBlock = true;

				if ( paramsBlock )
				{
					if ( !param && t.string != "..." )
					{
						param = new Field( "var", t.pos, t.string );
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
							_scope.type = new Multiname( t.string, imports[ imports.length - 1 ] );
						}
						else
							param.type = new Multiname( t.string, imports[ imports.length - 1 ] );
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
			if ( tp && tp.string == "for" && t.type == Token.STRING_LITERAL  )
			{
				field = new Field( "var", t.pos, t.string );
				
				if ( !scope.members.hasKey( t.string ) )
				{
					scope.members.setValue( t.string, field );
					_members.setValue( t.string, field );
				}
				
				access = "private";
				field.access = access;
				
				field.parent = scope;
			}
			else if ( t.string == "=" && tp.type == Token.STRING_LITERAL && !paramsBlock )
			{
				parsingVariables( tp, tp2, tokens.length - 2 )
			}

			

			if ( field && tp3 && tp.string == ":" )
			{
				if ( tp3.string == "var" || tp3.string == "const" || tp2.string == ")" )
				{
					if ( field.fieldType != "set" )
					{
						field.type = new Multiname( t.string, imports[ imports.length - 1 ] );
					}
					field = null;
				}
			}


			if ( (( tp && tp.string == ":" && t.type == Token.ENDLINE )
					|| ( tp2 && tp2.string == ":" && tp.type == Token.COMMENT && t.type == Token.ENDLINE )) && _scope )
			{	
				currentBlock = t;
				t.children = [];	
				position = pos;
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
				
				currentBlock.otstyp = { tabs : countTabToCurrentBlock, spaces : countSpaceToCurrentBlock };
				
				imports.push( imports[ imports.length - 1 ].clone() );
				currentBlock.imports = imports[ imports.length - 1 ];
				currentBlock.scope = scope;
				
				/*if ( !_scope )
					_scope = new Field( scope.fieldType, t.pos, "none" );*/
				
				
				_scope.parent = scope;
				_scope.children = [];
				scope.children.push( _scope );
				
				scope = _scope;
				t.scope = scope;
				
				//info += pos + ")" + scope.parent.name + "->" + scope.name+"\n";
				_scope = null;
			}
			
			return true;
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