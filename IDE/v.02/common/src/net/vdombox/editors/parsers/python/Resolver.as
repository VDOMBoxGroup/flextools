package net.vdombox.editors.parsers.python
{
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

		public function getAllOptions( pos : int ) : Vector.<String>
		{
			var f : Field;

			var a : Vector.<String> = new Vector.<String>();//all package level items
			
			// default keywords
				
			a.push( "AST" );
			a.push( "ArithmeticError" );
			a.push( "AssertionError" );
			a.push( "AttributeError" );
			a.push( "BaseHTTPServer" );
			a.push( "Bastion" );
			a.push( "CGIHTTPServer" );
			a.push( "Complex" );
			a.push( "EOFError" );
			a.push( "Exception" );
			a.push( "FloatingPointError" );
			a.push( "IOError" );
			a.push( "ImportError" );
			a.push( "IndentationError" );
			a.push( "IndexError" );
			a.push( "KeyError" );
			a.push( "KeyboardInterrupt" );
			a.push( "LookupError" );
			a.push( "MemoryError" );
			a.push( "Mimewriter" );
			a.push( "NameError" );
			a.push( "None" );
			a.push( "OverflowError" );
			a.push( "Para" );
			a.push( "Queue" );
			a.push( "RuntimeError" );
			a.push( "SimpleHTTPServer" );
			a.push( "SocketServer" );
			a.push( "StandardError" );
			a.push( "StringIO" );
			a.push( "SyntaxError" );
			a.push( "SystemError" );
			a.push( "SystemExit" );
			a.push( "TabError" );
			a.push( "Tkinter" );
			a.push( "TypeError" );
			a.push( "UserDict" );
			a.push( "UserList" );
			a.push( "ValueError" );
			a.push( "ZeroDivisionError" );
			a.push( "__abs__" );
			a.push( "__add__" );
			a.push( "__and__" );
			a.push( "__bases__" );
			a.push( "__call__" );
			a.push( "__class__" );
			a.push( "__cmp__" );
			a.push( "__coerce__" );
			a.push( "__del__" );
			a.push( "__delattr__" );
			a.push( "__delitem__" );
			a.push( "__delslice__" );
			a.push( "__dict__" );
			a.push( "__div__" );
			a.push( "__divmod__" );
			a.push( "__float__" );
			a.push( "__getattr__" );
			a.push( "__getitem__" );
			a.push( "__getslice__" );
			a.push( "__hash__" );
			a.push( "__hex__" );
			a.push( "__iadd__" );
			a.push( "__iand__" );
			a.push( "__idiv__" );
			a.push( "__ilshift__" );
			a.push( "__imod__" );
			a.push( "__import__" );
			a.push( "__init__" );
			a.push( "__int__" );
			a.push( "__invert__" );
			a.push( "__ior__" );
			a.push( "__ipow__" );
			a.push( "__irshift__" );
			a.push( "__isub__" );
			a.push( "__ixor__" );
			a.push( "__len__" );
			a.push( "__long__" );
			a.push( "__lshift__" );
			a.push( "__members__" );
			a.push( "__methods__" );
			a.push( "__mod__" );
			a.push( "__mul__" );
			a.push( "__name__" );
			a.push( "__neg__" );
			a.push( "__nonzero__" );
			a.push( "__oct__" );
			a.push( "__or__" );
			a.push( "__pos__" );
			a.push( "__pow__" );
			a.push( "__radd__" );
			a.push( "__rand__" );
			a.push( "__rdiv__" );
			a.push( "__rdivmod__" );
			a.push( "__repr__" );
			a.push( "__rlshift__" );
			a.push( "__rmod__" );
			a.push( "__rmul__" );
			a.push( "__ror__" );
			a.push( "__rpow__" );
			a.push( "__rrshift__" );
			a.push( "__rshift__" );
			a.push( "__rsub__" );
			a.push( "__rxor__" );
			a.push( "__setattr__" );
			a.push( "__setitem__" );
			a.push( "__setslice__" );
			a.push( "__str__" );
			a.push( "__sub__" );
			a.push( "__version__" );
			a.push( "__xor__" );
			a.push( "abs" );
			a.push( "and" );
			a.push( "apply" );
			a.push( "array" );
			a.push( "assert" );
			a.push( "atexit" );
			a.push( "break" );
			a.push( "callable" );
			a.push( "chr" );
			a.push( "class" );
			a.push( "cmd" );
			a.push( "cmp" );
			a.push( "codecs" );
			a.push( "coerce" );
			a.push( "commands" );
			a.push( "compile" );
			a.push( "compileall" );
			a.push( "complex" );
			a.push( "continue" );
			a.push( "copy" );
			a.push( "dbhash" );
			a.push( "def" );
			a.push( "del" );
			a.push( "delattr" );
			a.push( "dir" );
			a.push( "dircmp" );
			a.push( "dis" );
			a.push( "divmod" );
			a.push( "dospath" );
			a.push( "dumbdbm" );
			a.push( "elif" );
			a.push( "else" );
			a.push( "emacs" );
			a.push( "eval" );
			a.push( "except" );
			a.push( "exec" );
			a.push( "execfile" );
			a.push( "filter" );
			a.push( "finally" );
			a.push( "find" );
			a.push( "float" );
			a.push( "fmt" );
			a.push( "fnmatch" );
			a.push( "for" );
			a.push( "from" );
			a.push( "ftplib" );
			a.push( "getattr" );
			a.push( "getopt" );
			a.push( "glob" );
			a.push( "global" );
			a.push( "globals" );
			a.push( "gopherlib" );
			a.push( "grep" );
			a.push( "group" );
			a.push( "hasattr" );
			a.push( "hash" );
			a.push( "hex" );
			a.push( "htmllib" );
			a.push( "httplib" );
			a.push( "id" );
			a.push( "if" );
			a.push( "ihooks" );
			a.push( "imghdr" );
			a.push( "import" );
			a.push( "imputil" );
			a.push( "in" );
			a.push( "input" );
			a.push( "int" );
			a.push( "intern" );
			a.push( "is" );
			a.push( "isinstance" );
			a.push( "issubclass" );
			a.push( "joinfields" );
			a.push( "lambda" );
			a.push( "len" );
			a.push( "linecache" );
			a.push( "list" );
			a.push( "local" );
			a.push( "lockfile" );
			a.push( "long" );
			a.push( "macpath" );
			a.push( "macurl2path" );
			a.push( "mailbox" );
			a.push( "mailcap" );
			a.push( "map" );
			a.push( "match" );
			a.push( "math" );
			a.push( "max" );
			a.push( "mimetools" );
			a.push( "mimify" );
			a.push( "min" );
			a.push( "mutex" );
			a.push( "newdir" );
			a.push( "ni" );
			a.push( "nntplib" );
			a.push( "not" );
			a.push( "ntpath" );
			a.push( "nturl2path" );
			a.push( "oct" );
			a.push( "open" );
			a.push( "or" );
			a.push( "ord" );
			a.push( "os" );
			a.push( "ospath" );
			a.push( "pass" );
			a.push( "pdb" );
			a.push( "pickle" );
			a.push( "pipes" );
			a.push( "poly" );
			a.push( "popen2" );
			a.push( "posixfile" );
			a.push( "posixpath" );
			a.push( "pow" );
			a.push( "print" );
			a.push( "profile" );
			a.push( "pstats" );
			a.push( "pyclbr" );
			a.push( "pyexpat" );
			a.push( "quopri" );
			a.push( "raise" );
			a.push( "rand" );
			a.push( "random" );
			a.push( "range" );
			a.push( "raw_input" );
			a.push( "reduce" );
			a.push( "regex" );
			a.push( "regsub" );
			a.push( "reload" );
			a.push( "repr" );
			a.push( "return" );
			a.push( "rfc822" );
			a.push( "round" );
			a.push( "sched" );
			a.push( "search" );
			a.push( "self" );
			a.push( "setattr" );
			a.push( "setdefault" );
			a.push( "sgmllib" );
			a.push( "shelve" );
			a.push( "site" );
			a.push( "slice" );
			a.push( "sndhdr" );
			a.push( "snmp" );
			a.push( "splitfields" );
			a.push( "str" );
			a.push( "string" );
			a.push( "struct" );
			a.push( "sys" );
			a.push( "tb" );
			a.push( "tempfile" );
			a.push( "toaiff" );
			a.push( "token" );
			a.push( "tokenize" );
			a.push( "traceback" );
			a.push( "try" );
			a.push( "tty" );
			a.push( "tuple" );
			a.push( "type" );
			a.push( "types" );
			a.push( "tzparse" );
			a.push( "unichr" );
			a.push( "unicode" );
			a.push( "unicodedata" );
			a.push( "urllib" );
			a.push( "urlparse" );
			a.push( "util" );
			a.push( "uu" );
			a.push( "vars" );
			a.push( "wave" );
			a.push( "webbrowser" );
			a.push( "whatsound" );
			a.push( "whichdb" );
			a.push( "while" );
			a.push( "whrandom" );
			a.push( "xdrlib" );
			a.push( "xml" );
			a.push( "xmlpackage" );
			a.push( "xrange" );
			a.push( "zip" );
			a.push( "zmod" );
			
			for each ( f in typeDB.listAll() )
			{
				a.push( f.name );
				if ( !f.name )
					var tt : int = 0;
			}
			
			
			//find the scope
			var t : Token = tokenizer.tokenByPos( pos );
			if ( !t )
				return a;
			
			
			/*if ( t.scope.fieldType == 'class' )
			{
				a.push( 'private function ' );
				a.push( 'protected function ' );
				a.push( 'public function ' );
				a.push( 'private var ' );
				a.push( 'protected var ' );
				a.push( 'public var ' );
				a.push( 'static ' );
			}*/

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
				scope.fieldType == 'function' || scope.fieldType == 'get' || scope.fieldType == 'set'; scope = scope.parent )
			{
				addKeys( scope.members );
				addKeys( scope.params );
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
					if ( !isStatic || f.isStatic )
						a.push( f.name );
					

				//inheritance
				scope = tokenScopeClass;
				while ( ( scope = typeDB.resolveName( scope.extendz ) ) )
					for each ( f in scope.members.toArray() )
						if ( f.access != 'private' && ( !isStatic || f.isStatic ) )
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
			if ( !field || field.fieldType != 'function' )
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

			return 'function ' + field.name + '(' + a.join( ', ' ) + ')' + ( field.type ? ':' + field.type.type : '' );
		}

		/**
		 * called when you enter a dot
		 */
		public function getMemberList( text : String, pos : int ) : Vector.<String>
		{
			resolve( text, pos );
			if ( !resolved )
				return null;

			//convert member list in string list
			var a : Vector.<String> = new Vector.<String>;

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
			for each ( var m : Field in type.members.toArray() )
				if ( m.isStatic && ( m.access == 'public' || tokenScopeClass == type ) )
					map.setValue( m.name, m );
			return map;
		}


		private function listTypeMembers( type : Field, skipConstructor : Boolean = true ) : HashMap
		{
			if ( type.fieldType != 'class' && type.fieldType != 'interface' )
				throw new Error( 'type has to be class' );

			var map : HashMap = new HashMap;


			var protectedOK : Boolean = false;

			for ( ; type; type = typeDB.resolveName( type.extendz ) )
			{
				if ( tokenScopeClass == type )
				{
					protectedOK = true;
					map.merge( type.members );
					continue;
				}

				for each ( var m : Field in type.members.toArray() )
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

		private function resolve( text : String, pos : int ) : void
		{
			resolved = null;
			resolvedRef = null;
			resolvedIsClass = false;

			var t0 : Token = tokenizer.tokenByPos( pos );
			if ( t0.type == Token.COMMENT )
				return;

			var bp : BackwardsParser = new BackwardsParser;
			if ( !bp.parse( text, pos ) )
				return;

			//debug('bp names: '+bp.names);

			//find the scope
			var t : Token = tokenizer.tokenByPos( bp.startPos );
			if ( !t )
				return;

			var i : int = 0;
			var name : String = bp.names[ 0 ];
			var itemType : String = bp.types[ 0 ];

			var imports : HashMap = findImports( t );

			findScopeClass( t.scope );

			//1. is it in function scope chain?
			var isStatic : Boolean = false;
			for ( scope = t.scope; scope &&
				scope.fieldType == 'function' || scope.fieldType == 'get' || scope.fieldType == 'set'; scope = scope.parent )
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
			}

			var scope : Field;

			//2. is it this or super?
			if ( !resolved )
			{
				//non-static instance context
				var cond : Boolean = t.scope.parent && t.scope.parent.fieldType == 'class' && !isStatic;
				if ( name == 'this' && cond )
					resolved = t.scope.parent;
				if ( name == 'super' && cond )
					resolved = typeDB.resolveName( t.scope.parent.extendz );
			}


			//3. or is it in the class/inheritance scope?
			for ( scope = tokenScopeClass; !resolved && scope; scope = typeDB.resolveName( scope.extendz ) )
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
				return;
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
					return;
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


				if ( resolved.fieldType == 'var' || resolved.fieldType == 'get' || resolved.fieldType == 'set' ||
					( itemType == BackwardsParser.FUNCTION && resolved.fieldType == 'function' ) )
				{
					resolved = typeDB.resolveName( resolved.type );
				}
				else if ( resolved.fieldType == 'function' && itemType != BackwardsParser.FUNCTION )
				{
					resolved = typeDB.resolveName( new Multiname( 'Function' ) );
				}
			}
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