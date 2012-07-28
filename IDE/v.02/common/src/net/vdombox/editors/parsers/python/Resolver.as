package net.vdombox.editors.parsers.python
{
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.parsers.BackwardsParser;
	import net.vdombox.editors.parsers.Field;
	import net.vdombox.editors.parsers.Multiname;
	import net.vdombox.editors.parsers.StructureDB;
	import net.vdombox.editors.parsers.vdomxml.TypeDB;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	
	import ro.victordramba.util.HashMap;
	import net.vdombox.editors.parsers.ClassDB;


	internal class Resolver
	{
		private var classDB : ClassDB;
		private var typeDB : TypeDB;
		private var tokenizer : PythonTokenizer;

		private var tokenScopeClass : Field;
		
		private var a : Vector.<String>;

		public function Resolver( tokenizer : PythonTokenizer )
		{
			this.tokenizer = tokenizer;
			this.classDB = ClassDB.inst;
			this.typeDB = TypeDB.inst;
		}

		/**
		 * this only checks if the name is in the scope at pos, it will not look in the imports
		 * we use it to add an import only if it's not shadowed by a local name
		 */
		public function isInScope( name : String, pos : int ) : Boolean
		{
			//find the scope
			var t : PythonToken = PythonToken( tokenizer.tokenByPos( pos ) );
			if ( !t )
				return false;

			//check in function scope chain
			//also, find if we are in static scope
			var isStatic : Boolean = false;
			var scope : Field;
			var f : Field;
			for ( scope = t.scope; scope &&
				scope.fieldType == 'function' || scope.fieldType == 'get' || scope.fieldType == 'set'; scope = scope.parent )
			{
				if ( scope.members.hasKey( name ) || scope.params.hasKey( name ) )
					return true;
				if ( scope.isStatic )
					isStatic = true;
			}

			//compute tokenScopeClass
			findScopeClass( t.scope );

			//class scope
			if ( tokenScopeClass )
			{
				//for static scope, add only static members
				//current class
				for each ( f in tokenScopeClass.members.toArray() )
					if ( ( !isStatic || f.isStatic ) && f.name == name )
						return true;

				//inheritance
				scope = tokenScopeClass;
				while ( ( scope = classDB.resolveName( scope.extendz ) ) )
					for each ( f in scope.members.toArray() )
						if ( f.access != 'private' && ( !isStatic || f.isStatic ) && f.name == name )
							return true;
			}


			return false;
		}

		public function getMissingImports( name : String, pos : int ) : Vector.<String>
		{
			//find the scope
			var t : PythonToken = PythonToken( tokenizer.tokenByPos( pos ) );
			if ( !t )
				return null;
			var imports : HashMap = findImports( t );

			var found : Boolean = false;
			var missing : Vector.<String> = classDB.listImportsFor( name )
			loop1: for each ( var pack : String in missing )
			{
				for each ( var line : String in imports.toArray() )
				{
					var i : int = line.lastIndexOf( '.' );
					var n : String = line.substr( i + 1 );
					if ( line.substr( 0, i ) == pack && ( n == '*' || n == name ) )
					{
						found = true;
						break loop1;
					}
				}
			}

			if ( !found )
				return missing;
			return null;
		}

		public function getAllOptions( pos : int ) : Vector.<String>
		{	
			var f : Field;
			
			//all package level items
			var t : PythonToken = PythonToken( tokenizer.tokenByPos( pos ) );
			
			if (  t && ( t.type == PythonToken.COMMENT || t.type == PythonToken.STRING ) )
				return null;
			
			if ( t && ( t.string == "from" || t.importZone && !t.importFrom ) )
				return HashLibraryArray.getLibrariesName();
			else if ( t && t.importZone )
				return HashLibraryArray.getImportToLibraty( t.importFrom );
			
			// default keywords
			var a : Vector.<String> = new <String>["abs", "and", "apply", "ArithmeticError", "array", "assert", "AssertionError", "AST", "atexit", "AttributeError", "BaseHTTPServer", "Bastion", "break", "callable", "CGIHTTPServer", "chr", "class", "cmd", "cmp", "codecs", "coerce", "commands", "compile", "compileall", "Complex", "complex", "continue", "copy", "dbhash", "def", "del", "delattr", "dir", "dircmp", "dis", "divmod", "dospath", "dumbdbm", "elif", "else", "emacs", "EOFError", "eval", "except", "Exception", "exec", "execfile", "filter", "finally", "find", "float", "FloatingPointError", "fmt", "fnmatch", "for", "from", "ftplib", "getattr", "getopt", "glob", "global", "globals", "gopherlib", "grep", "group", "hasattr", "hash", "hex", "htmllib", "httplib", "id", "if", "ihooks", "imghdr", "import", "ImportError","imputil", "in", "IndentationError", "IndexError", "input", "int", "intern", "IOError", "is", "isinstance", "issubclass", "joinfields", "KeyError", "KeyboardInterrupt", "lambda", "len", "linecache", "list", "local", "lockfile", "long", "LookupError", "macpath", "macurl2path", "mailbox", "mailcap", "map", "match", "math", "max", "MemoryError", "mimetools", "Mimewriter", "mimify", "min", "mutex", "NameError", "newdir", "ni", "nntplib", "None", "not", "ntpath", "nturl2path", "oct", "open", "or", "ord", "os", "ospath", "OverflowError", "Para", "pass", "pdb", "pickle", "pipes", "poly", "popen2", "posixfile", "posixpath", "pow", "print", "profile", "pstats", "pyclbr", "pyexpat", "Queue", "quopri", "raise", "rand", "random", "range", "raw_input", "reduce", "request", "regex", "regsub", "reload", "repr", "return", "rfc822", "round", "RuntimeError", "sched", "search", "self", "session", "setattr", "setdefault", "sgmllib", "shelve", "SimpleHTTPServer", "site", "slice", "sndhdr", "snmp", "SocketServer", "splitfields", "StandardError", "str", "string", "StringIO", "struct", "SyntaxError", "sys", "SystemError", "SystemExit", "TabError", "tb", "tempfile", "Tkinter", "toaiff", "token", "tokenize", "traceback", "try", "tty", "tuple", "type", "TypeError", "types", "tzparse", "unichr", "unicode", "unicodedata", "urllib", "urlparse", "UserDict", "UserList", "util", "uu", "ValueError", "vars", "wave", "webbrowser", "whatsound", "whichdb", "while", "whrandom", "xdrlib", "xml", "xmlpackage", "xrange", "ZeroDivisionError",  "zip", "zmod"];
			
			/*for each ( f in classDB.listAll() )
			{
				a.push( f.name );
			}*/
			//find the scope
			if ( !t )
				return a;

			var hash : HashMap = new HashMap;
			var scope : Field;

			function addKeys( map : HashMap ) : void
			{
				for each ( var name : String in map.getKeys() )
					a.push( name);
			}
			
			//find items in function scope chain
			//also, find if we are in static scope
			var isStatic : Boolean = false;
			
			for ( scope = t.scope; scope &&
				scope.fieldType == 'def'; scope = scope.parent )
			{
				//addKeys( scope.members );
				addKeys( scope.params );
				if ( scope.isStatic )
					isStatic = true;
			}
				//for static scope, add only static members
				//current class
			for each ( f in tokenizer.members.toArray() )
				a.push( f.name );
				
			if ( t.parent.imports )
			{
				var ff : Object;
				for each ( ff in t.parent.imports.toArray() )
					a.push( ff.name );
			}
			
			/*if ( t.scope.fieldType == "class" || t.scope.fieldType == "top" )
			{
				for each ( f in t.scope.members.toArray() )
					a.push( f.name );
			}*/
			
			return a;
		}


		public function getAllTypes( isFunction : Boolean = true ) : Vector.<String>
		{
			var lst : Vector.<Field> = classDB.listAllTypes();
			var a : Vector.<String> = new Vector.<String>;
			for each ( var f : Field in lst )
				a.push( f.name );

			if ( isFunction )
				a.push( 'void' );

			a.sort( Array.CASEINSENSITIVE );
			return a;
		}

		public function getFunctionDetails( text : String, pos : int ) : String
		{
			resolve( text, pos );
			var field : Field = resolvedRef;

			//debug(field);

			//we didn't find it
			if ( !field || field.fieldType != 'def' )
				return null;


			var a : Vector.<String> = new Vector.<String>;
			var par : Field;
			for each ( par in field.params.toArray() )
			{
				var str : String = par.name;
				if ( par.type )
					str += ':' + par.type.type;
				if ( par.defaultValue )
					str += '=' + par.defaultValue;
				a.push( { label: str, value: str });
			}
			//rest
			if ( field.hasRestParams )
				a[ a.length - 1 ] = '...' + par.name;

			return 'def ' + field.name + '(' + a.join( ', ' ) + ')' + ( field.type ? ':' + field.type.type : '' );
		}

		/**
		 * called when you enter a dot
		 */
		public function getMemberList( text : String, pos : int, actionVO : Object ) : Vector.<String>
		{
			a = new Vector.<String>;
			
			var flag : Boolean = resolve( text, pos, actionVO );
			
			if ( flag )
				return a;
				
			
			if ( !resolved )
				if ( !a )
					return null;
				else
					return a;

			//convert member list in string list
			
			for each ( var m : Field in listMembers( resolved, resolvedIsClass ).toArray() )
			{
				if ( a.indexOf( m.name ) == -1 )
					a.push(m.name );
			}
			
			a.sort( Array.CASEINSENSITIVE );
			return a;
		}

		private function listMembers( type : Field, statics : Boolean ) : HashMap
		{
			return statics ? listStaticMembers( type ) : listTypeMembers( type );
		}

		private function listStaticMembers( type : Field ) : HashMap
		{
			var map : HashMap = new HashMap;
			for each ( var m : Field in type.members.toArray() )
				if ( ( m.isStatic || m.isClassMethod ) && ( m.access == 'public' || tokenScopeClass == type ) )
					map.setValue( m.name, m );
			return map;
		}


		private function listTypeMembers( type : Field, skipConstructor : Boolean = true ) : HashMap
		{
			/*if ( type.fieldType != 'class' && type.fieldType != 'interface' )
				throw new Error( 'type has to be class' );*/

			var map : HashMap = new HashMap;


			var protectedOK : Boolean = false;

			for ( ; type; type = classDB.resolveName( type.extendz ) )
			{
				if ( tokenScopeClass == type )
				{
					protectedOK = true;
					for each ( var m : Field in type.members.toArray() )
					{
						if ( m.isStatic )
							continue;
						if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) )
							map.setValue( m.name, m );
					}
					continue;
				}

				for each ( m  in type.members.toArray() )
				{
					if ( m.isStatic )
						continue;
					if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) )
						map.setValue( m.name, m );
				}
				
				/*for each ( m in type.selfMembers.toArray() )
				{
					if ( m.isStatic )
						continue;
					var constrCond : Boolean = ( m.name == type.name ) && skipConstructor;
					if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) && !constrCond )
						map.setValue( m.name, m );
				}*/
			}

			return map;
		}


		public function findDefinition( text : String, pos : int ) : Field
		{
			//adjust position to next word boundary
			var re : RegExp = /\b/g;
			re.lastIndex = pos;
			pos = re.exec( text ).index;
			resolve( text, pos );
			return resolvedRef;
		}

		//find the imports for this token
		private function findImports( token : PythonToken ) : HashMap
		{
			do
			{
				token = token.parent as PythonToken;
			} while ( token.parent && !token.imports );
			return token.imports;
		}


		private var resolved : Field;
		private var resolvedIsClass : Boolean;
		private var resolvedRef : Field;

		private function resolve( text : String, pos : int, actionVO : Object = null ) : Boolean
		{
			resolved = null;
			resolvedRef = null;
			resolvedIsClass = false;

			var t0 : PythonToken = PythonToken( tokenizer.tokenByPos( pos ) );
			if ( t0.type == PythonToken.COMMENT || t0.type == PythonToken.STRING )
				return false;

			var bp : BackwardsParser = new BackwardsParser;
			if ( !bp.parse( text, pos ) )
				return false;

			//find the scope
			var t : PythonToken = PythonToken( tokenizer.tokenByPos( bp.startPos ) );
			if ( !t )
				return false;

			var i : int = 0;
			var name : String = bp.names[ 0 ];
			var itemType : String = bp.types[ 0 ];

			var imports : HashMap = findImports( t );

			findScopeClass( t.scope );

			//1. is it in function scope chain?
			var isStatic : Boolean = false;
			for ( scope = t.scope; scope && ( scope.fieldType == 'def' || scope.fieldType == 'top' || scope.fieldType == 'class' ); scope = scope.parent )
			{
				if ( scope.isStatic )
					isStatic = true;
				if ( scope.members.hasKey( name ) )
				{
					resolved = scope.members.getValue( name );
					break;
				}
				if ( scope.params.hasKey( name ) )
				{
					resolved = scope.params.getValue( name );
					break;
				}
				if ( t.parent.imports.hasKey( name ) )
				{
					var impotrElement : Object = t.parent.imports.getValue( name );
					a = HashLibraryArray.getTokensToLibratyClass( impotrElement.source, impotrElement.systemName, bp );
					return true;
					//return hashLibraries.getTokensToLibratyClass( t.imports.getValue( name ).source, impotrElement.systemName );
				}
					
			}

			var scope : Field;

			//2. is it this or super?
			
			if ( name == 'self' && tokenScopeClass )
			{
				if ( resolved )
					tokenScopeClass.members.merge( resolved.members );
				resolved = tokenScopeClass;
				
				for each( var field : Field in tokenScopeClass.members.toArray() )
				{
					if ( field.parent.name == tokenScopeClass.name )
						resolved.members.setValue( field.name, field );
				}
			}
			
			
			if ( name == 'self' && actionVO is ServerActionVO && !tokenScopeClass )
			{
				a = StructureDB.getChildrenForObject( ServerActionVO( actionVO ).containerVO, bp );
			}


			//3. or is it in the class/inheritance scope?
			for ( scope = tokenScopeClass; !resolved && scope; scope = classDB.resolveName(scope.extendz) )
			{
				var m : Field = scope.members.getValue( name );
				if ( !m )
					continue;

				if ( scope != tokenScopeClass && m.access == 'private' )
					continue;

				//skip constructors in inheritance chain
				if ( m.name == scope.name )
					continue;

				if ( !isStatic || m.isStatic )
					resolved = m;
			}

			//4. last, is it an imported thing?
			if ( !resolved && imports )
			{
				resolved = classDB.resolveName( new Multiname( name, imports ) );
				
			}

			//we didn't find the first name, we quit
			if ( !resolved )
				return false;
			else if ( resolved.fieldType == 'class' && itemType == BackwardsParser.NAME && name != 'self' )
				resolvedIsClass = true;
			
			checkReturnType();


			var aM : HashMap;
			do
			{
				i++;
				if ( i > bp.names.length - 1 )
					break;
				aM = listMembers( resolved, resolvedIsClass );
				resolved = aM.getValue( bp.names[ i ] );
				resolvedIsClass = false;
				itemType = bp.types[ i ];
				if ( !resolved )
					return false;
				checkReturnType();
			} while ( resolved );

			//check return type or var type
			function checkReturnType() : void
			{
				//for function signature
				resolvedRef = resolved;
				if ( resolved.fieldType == 'class' && resolvedIsClass ) //return the constructor
				{
					var m : Field = resolved.members.getValue( resolved.name );
					if ( m )
						resolvedRef = m;
				}


				/*if ( resolved.type && resolved.fieldType == 'var' || resolved.fieldType == 'get' || resolved.fieldType == 'set' ||
					( itemType == BackwardsParser.FUNCTION && resolved.fieldType == 'def' ) )
				{
					resolved = typeDB.resolveName( resolved.type );
				}
				else*/ if ( resolved.fieldType == 'def' && itemType != BackwardsParser.FUNCTION )
				{
					resolved = classDB.resolveName( new Multiname( 'Def' ) );
				}
			}
			
			return false;
		}

		private function findScopeClass( scope : Field ) : void
		{
			//can we find a better way to set the scope?
			//we set the scope to be able to deal with private/protected, etc access
			for ( tokenScopeClass = scope; tokenScopeClass.fieldType != 'class' && tokenScopeClass.parent; tokenScopeClass = tokenScopeClass.parent )
			{
			}
			if ( tokenScopeClass.fieldType != 'class' )
				tokenScopeClass = null;
		}
	}
}