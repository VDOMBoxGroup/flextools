package net.vdombox.editors.parsers.python
{
	import net.vdombox.editors.HashLibraryArray;
	
	import ro.victordramba.util.HashMap;


	internal class Resolver
	{
		private var typeDB : TypeDB;
		private var tokenizer : Tokenizer;

		private var tokenScopeClass : Field;

		public function Resolver( tokenizer : Tokenizer )
		{
			this.tokenizer = tokenizer;
			this.typeDB = TypeDB.inst;
		}

		/**
		 * this only checks if the name is in the scope at pos, it will not look in the imports
		 * we use it to add an import only if it's not shadowed by a local name
		 */
		public function isInScope( name : String, pos : int ) : Boolean
		{
			//find the scope
			var t : Token = tokenizer.tokenByPos( pos );
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
				while ( ( scope = typeDB.resolveName( scope.extendz ) ) )
					for each ( f in scope.members.toArray() )
						if ( f.access != 'private' && ( !isStatic || f.isStatic ) && f.name == name )
							return true;
			}


			return false;
		}

		public function getMissingImports( name : String, pos : int ) : Vector.<String>
		{
			//find the scope
			var t : Token = tokenizer.tokenByPos( pos );
			if ( !t )
				return null;
			var imports : HashMap = findImports( t );

			var found : Boolean = false;
			var missing : Vector.<String> = typeDB.listImportsFor( name )
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

		public function getAllOptions( pos : int, hashLibraries : HashLibraryArray ) : Vector.<String>
		{
			
			var f : Field;
			
			//all package level items
			var t : Token = tokenizer.tokenByPos( pos );
			
			if ( t && ( t.string == "from" || t.importZone && !t.importFrom ) )
				return hashLibraries.getLibrariesName();
			else if ( t && t.importZone )
				return hashLibraries.getImportToLibraty( t.importFrom );
			
			// default keywords
	//		var a : Vector.<String> = new <String>["__abs__", "__add__", "__and__", "__bases__", "__call__", "__class__", "__cmp__", "__coerce__", "__del__", "__delattr__", "__delitem__", "__delslice__", "__dict__", "__div__", "__divmod__", "__float__", "__getattr__", "__getitem__", "__getslice__", "__hash__", "__hex__", "__iadd__", "__iand__", "__idiv__", "__ilshift__", "__imod__", "__import__", "__init__", "__int__", "__invert__", "__ior__", "__ipow__", "__irshift__", "__isub__", "__ixor__", "__len__", "__long__", "__lshift__", "__members__", "__methods__", "__mod__", "__mul__", "__name__", "__neg__", "__nonzero__", "__oct__", "__or__", "__pos__", "__pow__", "__radd__", "__rand__", "__rdiv__", "__rdivmod__", "__repr__", "__rlshift__", "__rmod__", "__rmul__", "__ror__", "__rpow__", "__rrshift__", "__rshift__", "__rsub__", "__rxor__", "__setattr__", "__setitem__", "__setslice__", "__str__", "__sub__", "__version__", "__xor__", "abs", "and", "apply", "ArithmeticError", "array", "assert", "AssertionError", "AST", "atexit", "AttributeError", "BaseHTTPServer", "Bastion", "break", "callable", "CGIHTTPServer", "chr", "class", "cmd", "cmp", "codecs", "coerce", "commands", "compile", "compileall", "Complex", "complex", "continue", "copy", "dbhash", "def", "del", "delattr", "dir", "dircmp", "dis", "divmod", "dospath", "dumbdbm", "elif", "else", "emacs", "EOFError", "eval", "except", "Exception", "exec", "execfile", "filter", "finally", "find", "float", "FloatingPointError", "fmt", "fnmatch", "for", "from", "ftplib", "getattr", "getopt", "glob", "global", "globals", "gopherlib", "grep", "group", "hasattr", "hash", "hex", "htmllib", "httplib", "id", "if", "ihooks", "imghdr", "import", "ImportError","imputil", "in", "IndentationError", "IndexError", "input", "int", "intern", "IOError", "is", "isinstance", "issubclass", "joinfields", "KeyError", "KeyboardInterrupt", "lambda", "len", "linecache", "list", "local", "lockfile", "long", "LookupError", "macpath", "macurl2path", "mailbox", "mailcap", "map", "match", "math", "max", "MemoryError", "mimetools", "Mimewriter", "mimify", "min", "mutex", "NameError", "newdir", "ni", "nntplib", "None", "not", "ntpath", "nturl2path", "oct", "open", "or", "ord", "os", "ospath", "OverflowError", "Para", "pass", "pdb", "pickle", "pipes", "poly", "popen2", "posixfile", "posixpath", "pow", "print", "profile", "pstats", "pyclbr", "pyexpat", "Queue", "quopri", "raise", "rand", "random", "range", "raw_input", "reduce", "regex", "regsub", "reload", "repr", "return", "rfc822", "round", "RuntimeError", "sched", "search", "self", "setattr", "setdefault", "sgmllib", "shelve", "SimpleHTTPServer", "site", "slice", "sndhdr", "snmp", "SocketServer", "splitfields", "StandardError", "str", "string", "StringIO", "struct", "SyntaxError", "sys", "SystemError", "SystemExit", "TabError", "tb", "tempfile", "Tkinter", "toaiff", "token", "tokenize", "traceback", "try", "tty", "tuple", "type", "TypeError", "types", "tzparse", "unichr", "unicode", "unicodedata", "urllib", "urlparse", "UserDict", "UserList", "util", "uu", "ValueError", "vars", "wave", "webbrowser", "whatsound", "whichdb", "while", "whrandom", "xdrlib", "xml", "xmlpackage", "xrange", "ZeroDivisionError",  "zip", "zmod"];
			var a : Vector.<String> = new <String>["__abs__", "__add__", "__and__", "__bases__", "__call__", "__class__", "__cmp__", "__coerce__", "__del__", "__delattr__", "__delitem__", "__delslice__", "__dict__", "__div__", "__divmod__", "__float__", "__getattr__", "__getitem__", "__getslice__", "__hash__", "__hex__", "__iadd__", "__iand__", "__idiv__", "__ilshift__", "__imod__", "__import__", "__init__", "__int__", "__invert__", "__ior__", "__ipow__", "__irshift__", "__isub__", "__ixor__", "__len__", "__long__", "__lshift__", "__members__", "__methods__", "__mod__", "__mul__", "__name__", "__neg__", "__nonzero__", "__oct__", "__or__", "__pos__", "__pow__", "__radd__", "__rand__", "__rdiv__", "__rdivmod__", "__repr__", "__rlshift__", "__rmod__", "__rmul__", "__ror__", "__rpow__", "__rrshift__", "__rshift__", "__rsub__", "__rxor__", "__setattr__", "__setitem__", "__setslice__", "__str__", "__sub__", "__version__", "__xor__", "abs", "and", "apply", "ArithmeticError", "array", "assert", "AssertionError", "AST", "atexit", "AttributeError", "BaseHTTPServer", "Bastion", "break", "callable", "CGIHTTPServer", "chr", "class", "cmd", "cmp", "codecs", "coerce", "commands", "compile", "compileall", "Complex", "complex", "continue", "copy", "dbhash", "def", "del", "delattr", "dir", "dircmp", "dis", "divmod", "dospath", "dumbdbm", "elif", "else", "emacs", "EOFError", "eval", "except", "Exception", "exec", "execfile", "filter", "finally", "find", "float", "FloatingPointError", "fmt", "fnmatch", "for", "from", "ftplib", "getattr", "getopt", "glob", "global", "globals", "gopherlib", "grep", "group", "hasattr", "hash", "hex", "htmllib", "httplib", "id", "if", "ihooks", "imghdr", "import", "ImportError","imputil", "in", "IndentationError", "IndexError", "input", "int", "intern", "IOError", "is", "isinstance", "issubclass", "joinfields", "KeyError", "KeyboardInterrupt", "lambda", "len", "linecache", "list", "local", "lockfile", "long", "LookupError", "macpath", "macurl2path", "mailbox", "mailcap", "map", "match", "math", "max", "MemoryError", "mimetools", "Mimewriter", "mimify", "min", "mutex", "NameError", "newdir", "ni", "nntplib", "None", "not", "ntpath", "nturl2path", "oct", "open", "or", "ord", "os", "ospath", "OverflowError", "Para", "pass", "pdb", "pickle", "pipes", "poly", "popen2", "posixfile", "posixpath", "pow", "print", "profile", "pstats", "pyclbr", "pyexpat", "Queue", "quopri", "raise", "rand", "random", "range", "raw_input", "reduce", "regex", "regsub", "reload", "repr", "return", "rfc822", "round", "RuntimeError", "sched", "search", "self", "setattr", "setdefault", "sgmllib", "shelve", "SimpleHTTPServer", "site", "slice", "sndhdr", "snmp", "SocketServer", "splitfields", "StandardError", "str", "string", "StringIO", "struct", "SyntaxError", "sys", "SystemError", "SystemExit", "TabError", "tb", "tempfile", "Tkinter", "toaiff", "token", "tokenize", "traceback", "try", "tty", "tuple", "type", "TypeError", "types", "tzparse", "unichr", "unicode", "unicodedata", "urllib", "urlparse", "UserDict", "UserList", "util", "uu", "ValueError", "vars", "wave", "webbrowser", "whatsound", "whichdb", "while", "whrandom", "xdrlib", "xml", "xmlpackage", "xrange", "ZeroDivisionError",  "zip", "zmod"];
			
			
			for each ( f in typeDB.listAll() )
			{
				a.push( f.name );
			}
			
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

			//compute tokenScopeClass
			//findScopeClass( t.scope );

			//class scope
			if ( t.scope.members )
			{
				//for static scope, add only static members
				//current class
				for each ( f in t.scope.members.toArray() )
					a.push( f.name );
				
				//inheritance
				/*scope = tokenScopeClass;
				while ( ( scope = typeDB.resolveName( scope.extendz ) ) )
					for each ( f in scope.members.toArray() )
						if ( f.access != 'private' && ( !isStatic || f.isStatic ) )
							a.push( f.name );*/
				
			}
			
			if ( t.parent.imports )
			{
				var ff : Object;
				for each ( ff in t.parent.imports.toArray() )
					a.push( ff.name );
			}
			
			if ( t.scope.fieldType == "class" || t.scope.fieldType == "top" && t.scope.selfMembers )
			{
				for each ( f in t.scope.selfMembers.toArray() )
					a.push( f.name );
			}
			
			return a;
		}


		public function getAllTypes( isFunction : Boolean = true ) : Vector.<String>
		{
			var lst : Vector.<Field> = typeDB.listAllTypes();
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
		public function getMemberList( text : String, pos : int, hashLibraries : HashLibraryArray ) : Vector.<String>
		{
			var a : Vector.<String> = resolve( text, pos, hashLibraries );
			
			if ( a )
				return a;
			else
				a = new Vector.<String>;
			
			if ( !resolved )
				return null;

			//convert member list in string list
			

			for each ( var m : Field in listMembers( resolved, resolvedIsClass ).toArray() )
				a.push(m.name );
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
			for each ( var m : Field in type.selfMembers.toArray() )
				if ( m.isStatic && ( m.access == 'public' || tokenScopeClass == type ) )
					map.setValue( m.name, m );
			return map;
		}


		private function listTypeMembers( type : Field, skipConstructor : Boolean = true ) : HashMap
		{
			/*if ( type.fieldType != 'class' && type.fieldType != 'interface' )
				throw new Error( 'type has to be class' );*/

			var map : HashMap = new HashMap;


			var protectedOK : Boolean = false;

			for ( ; type; type = typeDB.resolveName( type.extendz ) )
			{
				if ( tokenScopeClass == type )
				{
					protectedOK = true;
					for each ( var m : Field in type.selfMembers.toArray() )
					{
						if ( m.isStatic )
							continue;
						if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) && !constrCond )
							map.setValue( m.name, m );
					}
					continue;
				}

				for each ( m  in type.members.toArray() )
				{
					if ( m.isStatic )
						continue;
					if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) && !constrCond )
						map.setValue( m.name, m );
				}
				
				for each ( m in type.selfMembers.toArray() )
				{
					if ( m.isStatic )
						continue;
					var constrCond : Boolean = ( m.name == type.name ) && skipConstructor;
					if ( ( m.access == 'public' || ( protectedOK && m.access == 'protected' ) ) && !constrCond )
						map.setValue( m.name, m );
				}
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
		private function findImports( token : Token ) : HashMap
		{
			do
			{
				token = token.parent;
			} while ( token.parent && !token.imports );
			return token.imports;
		}


		private var resolved : Field;
		private var resolvedIsClass : Boolean;
		private var resolvedRef : Field;

		private function resolve( text : String, pos : int, hashLibraries : HashLibraryArray = null ) : Vector.<String>
		{
			resolved = null;
			resolvedRef = null;
			resolvedIsClass = false;

			var t0 : Token = tokenizer.tokenByPos( pos );
			if ( t0.type == Token.COMMENT )
				return null;
			
			/*if ( t0.parent.imports && t0.parent.imports.hasKey( t0.string ) )
			{
				var impotrElement : Object = t0.parent.imports.getValue( t0.string );
				return hashLibraries.getTokensToLibratyClass( impotrElement.source, impotrElement.systemName );
			}*/

			var bp : BackwardsParser = new BackwardsParser;
			if ( !bp.parse( text, pos ) )
				return null;

			//debug('bp names: '+bp.names);

			//find the scope
			var t : Token = tokenizer.tokenByPos( bp.startPos );
			if ( !t )
				return null;

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
				if ( scope.selfMembers.hasKey( name ) )
				{
					resolved = scope.selfMembers.getValue( name );
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
					return hashLibraries.getTokensToLibratyClass( impotrElement.source, impotrElement.systemName, bp );
					//return hashLibraries.getTokensToLibratyClass( t.imports.getValue( name ).source, impotrElement.systemName );
				}
					
			}

			var scope : Field;

			//2. is it this or super?
			
			if ( name == 'self' && tokenScopeClass )
			{
				if ( resolved )
					tokenScopeClass.selfMembers.merge( resolved.members );
				resolved = tokenScopeClass;
				
				for each( var field : Field in tokenScopeClass.members.toArray() )
				{
					if ( field.parent.name == tokenScopeClass.name )
						resolved.selfMembers.setValue( field.name, field );
				}
			}
			
			if ( resolved )
			{
				//non-static instance context
				
				if ( name == 'super' )
					resolved = typeDB.resolveName( t.scope.parent.extendz );
			}


			//3. or is it in the class/inheritance scope?
			for ( scope = tokenScopeClass; !resolved && scope; scope = typeDB.resolveName(scope.extendz) )
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
				resolved = typeDB.resolveName( new Multiname( name, imports ) );
				if ( resolved && resolved.fieldType == 'class' && itemType == BackwardsParser.NAME )
					resolvedIsClass = true;
			}

			//we didn't find the first name, we quit
			if ( !resolved )
				return null;
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
					return null;
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
					resolved = typeDB.resolveName( new Multiname( 'Def' ) );
				}
			}
			
			return null;
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