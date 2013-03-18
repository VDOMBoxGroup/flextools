package net.vdombox.editors.parsers.python
{
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashList;

	public class PythonWordsStorage
	{
		public function PythonWordsStorage()
		{
		}
		
		
		private static var _pythonWordsString : Vector.<String> = new <String>["abs", "and", "application", "apply", "ArithmeticError", "array", "assert", "AssertionError", "AST", "atexit", "AttributeError", "BaseHTTPServer", "Bastion", "break", "callable", "CGIHTTPServer", "chr", "class", "classmethod", "cmd", "cmp", "codecs", "coerce", "commands", "compile", "compileall", "Complex", "complex", "continue", "copy", "dbhash", "def", "del", "delattr", "dir", "dircmp", "dis", "divmod", "dospath", "dumbdbm", "elif", "else", "emacs", "EOFError", "eval", "except", "Exception", "exec", "execfile", "filter", "finally", "find", "float", "FloatingPointError", "fmt", "fnmatch", "for", "from", "ftplib", "getattr", "getopt", "glob", "global", "globals", "gopherlib", "grep", "group", "hasattr", "hash", "hex", "htmllib", "httplib", "id", "if", "ihooks", "imghdr", "import", "ImportError","imputil", "in", "IndentationError", "IndexError", "input", "int", "intern", "IOError", "is", "isinstance", "issubclass", "joinfields", "KeyError", "KeyboardInterrupt", "lambda", "len", "linecache", "list", "local", "lockfile", "long", "LookupError", "macpath", "macurl2path", "mailbox", "mailcap", "map", "match", "math", "max", "MemoryError", "mimetools", "Mimewriter", "mimify", "min", "mutex", "NameError", "newdir", "ni", "nntplib", "None", "not", "ntpath", "nturl2path", "oct", "open", "or", "ord", "os", "ospath", "OverflowError", "Para", "pass", "pdb", "pickle", "pipes", "poly", "popen2", "posixfile", "posixpath", "pow", "print", "profile", "property", "pstats", "pyclbr", "pyexpat", "Queue", "quopri", "raise", "rand", "random", "range", "raw_input", "reduce", "response", "request", "regex", "regsub", "reload", "repr", "return", "rfc822", "round", "RuntimeError", "sched", "search", "self", "server", "session", "setattr", "setdefault", "sgmllib", "shelve", "SimpleHTTPServer", "site", "slice", "sndhdr", "snmp", "SocketServer", "splitfields", "StandardError", "staticmethod", "str", "string", "StringIO", "struct", "SyntaxError", "sys", "SystemError", "SystemExit", "TabError", "tb", "tempfile", "Tkinter", "toaiff", "token", "tokenize", "traceback", "try", "tty", "tuple", "type", "TypeError", "types", "tzparse", "unichr", "unicode", "unicodedata", "urllib", "urlparse", "UserDict", "UserList", "util", "uu", "ValueError", "vars", "wave", "webbrowser", "whatsound", "whichdb", "while", "whrandom", "xdrlib", "xml", "xmlpackage", "xrange", "ZeroDivisionError",  "zip", "zmod"];
		
		private static var _pythonWordsAutocomplete : Vector.<AutoCompleteItemVO>;
		private static var _pythonWords : HashList;
		private static var _pythonFields : HashList;
		
		public static function get pythonWordsAutocomplete():Vector.<AutoCompleteItemVO>
		{
			_pythonWordsAutocomplete = new Vector.<AutoCompleteItemVO>();
			
			for each( var item : String in _pythonWordsString )
			{
				_pythonWordsAutocomplete.push( new AutoCompleteItemVO( VDOMImage.Standard, item ) );
			}
			
			return _pythonWordsAutocomplete;
		}
		
		public static function getAutocompleteItemVOByName( name : String ) : AutoCompleteItemVO
		{
			if ( !_pythonWords )
				init();
			
			return _pythonWords.getValue( name );
			
		}
		
		public static function getFieldByName( name : String ) : Field
		{
			if ( !_pythonFields )
				init();
			
			return _pythonFields.getValue( name );
			
		}

		private static function init() : void
		{

			_pythonWords = new HashList();
			
			
			_pythonWords.setValue( "abs", 					new AutoCompleteItemVO( VDOMImage.Standard, "abs", "abs(x)", "Return the absolute value of a number. The argument may be a plain or long integer or a floating point number. If the argument is a complex number, its magnitude is returned." ) );
			_pythonWords.setValue( "and", 					new AutoCompleteItemVO( VDOMImage.Standard, "and", "", "The expression x and y first evaluates x; if x is false, its value is returned; otherwise, y is evaluated and the resulting value is returned." ) );
			_pythonWords.setValue( "application", 			new AutoCompleteItemVO( VDOMImage.Standard, "application", "", "" ) );
			_pythonWords.setValue( "apply", 				new AutoCompleteItemVO( VDOMImage.Standard, "apply", "apply(function, args[, keywords])", "The function argument must be a callable object (a user-defined or built-in function or method, or a class object) and the args argument must be a sequence. The function is called with args as the argument list; the number of arguments is the length of the tuple. If the optional keywords argument is present, it must be a dictionary whose keys are strings. It specifies keyword arguments to be added to the end of the argument list. Calling apply() is different from just calling function(args), since in that case there is always exactly one argument. The use of apply() is equivalent to function(*args, **keywords)." ) );
			_pythonWords.setValue( "ArithmeticError", 		new AutoCompleteItemVO( VDOMImage.Standard, "ArithmeticError", "", "The base class for those built-in exceptions that are raised for various arithmetic errors: OverflowError, ZeroDivisionError, FloatingPointError." ) );
			_pythonWords.setValue( "array", 				new AutoCompleteItemVO( VDOMImage.Standard, "array", "", "" ) );
			_pythonWords.setValue( "assert", 				new AutoCompleteItemVO( VDOMImage.Standard, "assert", "", "" ) );
			_pythonWords.setValue( "AssertionError", 		new AutoCompleteItemVO( VDOMImage.Standard, "AssertionError", "", "Raised when an assert statement fails." ) );
			_pythonWords.setValue( "AST", 					new AutoCompleteItemVO( VDOMImage.Standard, "AST", "", "" ) );
			_pythonWords.setValue( "atexit", 				new AutoCompleteItemVO( VDOMImage.Standard, "atexit", "", "The atexit module defines a single function to register cleanup functions. Functions thus registered are automatically executed upon normal interpreter termination.\n" +
				"\n" +
				"<b>Example</b>\n" +
				"def goodbye(name, adjective):\n"+
   				" print 'Goodbye, %s, it was %s to meet you.' % (name, adjective)\n" +
				"\n" +
				"import atexit\n"+
				"atexit.register(goodbye, 'Donny', 'nice')\n"+
				"\n"+
				"# or:\n"+
				"atexit.register(goodbye, adjective='nice', name='Donny')" ) );
			
			_pythonWords.setValue( "AttributeError", 		new AutoCompleteItemVO( VDOMImage.Standard, "AttributeError", "", "Raised when an attribute reference (see Attribute references) or assignment fails. (When an object does not support attribute references or attribute assignments at all, TypeError is raised.)" ) );
			_pythonWords.setValue( "BaseHTTPServer", 		new AutoCompleteItemVO( VDOMImage.Standard, "BaseHTTPServer", "", "This module defines two classes for implementing HTTP servers (Web servers). Usually, this module isn’t used directly, but is used as a basis for building functioning Web servers. See the SimpleHTTPServer and CGIHTTPServer modules." ) );
			_pythonWords.setValue( "break", 				new AutoCompleteItemVO( VDOMImage.Standard, "break", "", "" ) );
			_pythonWords.setValue( "callable",				new AutoCompleteItemVO( VDOMImage.Standard, "callable", "callable(object) ", "Return True if the object argument appears callable, False if not. If this returns true, it is still possible that a call fails, but if it is false, calling object will never succeed. Note that classes are callable (calling a class returns a new instance); class instances are callable if they have a __call__() method." ) );
			_pythonWords.setValue( "CGIHTTPServer", 		new AutoCompleteItemVO( VDOMImage.Standard, "CGIHTTPServer", "", "" ) );
			_pythonWords.setValue( "chr", 					new AutoCompleteItemVO( VDOMImage.Standard, "chr", "chr(i)", "Return a string of one character whose ASCII code is the integer i. For example, chr(97) returns the string 'a'. This is the inverse of ord(). The argument must be in the range [0..255], inclusive; ValueError will be raised if i is outside that range. See also unichr()." ) );
			_pythonWords.setValue( "class", 				new AutoCompleteItemVO( VDOMImage.Standard, "class", "", "A template for creating user-defined objects. Class definitions normally contain method definitions which operate on instances of the class. " ) );
			_pythonWords.setValue( "classmethod", 			new AutoCompleteItemVO( VDOMImage.Standard, "classmethod", "", "" ) );
			_pythonWords.setValue( "cmd", 					new AutoCompleteItemVO( VDOMImage.Standard, "cmd", "", "" ) );
			_pythonWords.setValue( "cmp", 					new AutoCompleteItemVO( VDOMImage.Standard, "cmp", "cmp(x, y)", "Compare the two objects x and y and return an integer according to the outcome. The return value is negative if x < y, zero if x == y and strictly positive if x > y." ) );
			_pythonWords.setValue( "codecs", 				new AutoCompleteItemVO( VDOMImage.Standard, "codecs", "", "This module defines base classes for standard Python codecs (encoders and decoders) and provides access to the internal Python codec registry which manages the codec and error handling lookup process." ) );
			_pythonWords.setValue( "coerce", 				new AutoCompleteItemVO( VDOMImage.Standard, "coerce", "coerce(x, y)", "Return a tuple consisting of the two numeric arguments converted to a common type, using the same rules as used by arithmetic operations. If coercion is not possible, raise TypeError." ) );
			_pythonWords.setValue( "compile", 				new AutoCompleteItemVO( VDOMImage.Standard, "compile", "compile(source, filename, mode[, flags[, dont_inherit]])", "Compile the source into a code or AST object. Code objects can be executed by an exec statement or evaluated by a call to eval(). source can either be a string or an AST object. Refer to the ast module documentation for information on how to work with AST objects.\n\n"+

				"The filename argument should give the file from which the code was read; pass some recognizable value if it wasn’t read from a file ('<string>' is commonly used).\n\n"+

				"The mode argument specifies what kind of code must be compiled; it can be 'exec' if source consists of a sequence of statements, 'eval' if it consists of a single expression, or 'single' if it consists of a single interactive statement (in the latter case, expression statements that evaluate to something other than None will be printed).\n\n"+

				"The optional arguments flags and dont_inherit control which future statements (see PEP 236) affect the compilation of source. If neither is present (or both are zero) the code is compiled with those future statements that are in effect in the code that is calling compile. If the flags argument is given and dont_inherit is not (or is zero) then the future statements specified by the flags argument are used in addition to those that would be used anyway. If dont_inherit is a non-zero integer then the flags argument is it – the future statements in effect around the call to compile are ignored.\n\n" +

				"Future statements are specified by bits which can be bitwise ORed together to specify multiple statements. The bitfield required to specify a given feature can be found as the compiler_flag attribute on the _Feature instance in the __future__ module.\n\n" + 

				"This function raises SyntaxError if the compiled source is invalid, and TypeError if the source contains null bytes." ) );
			
			_pythonWords.setValue( "compileall", 			new AutoCompleteItemVO( VDOMImage.Standard, "compileall", "", "" ) );
			_pythonWords.setValue( "Complex", 				new AutoCompleteItemVO( VDOMImage.Standard, "Complex", "", "Subclasses of this type describe complex numbers and include the operations that work on the built-in complex type. These are: conversions to complex and bool, real, imag, +, -, *, /, abs(), conjugate(), ==, and !=. All except - and != are abstract.\n\n" +

				"<b>real</b>\n " +
				"<t>Abstract. Retrieves the real component of this number.\n\n" +
				"<b>imag</b>\n " + 
				"<t>Abstract. Retrieves the imaginary component of this number.\n\n" + 
				"<b>conjugate()</b>\n" + 
				"<t>Abstract. Returns the complex conjugate. For example, (1+3j).conjugate() == (1-3j)." ) );
			
			_pythonWords.setValue( "complex", 				new AutoCompleteItemVO( VDOMImage.Standard, "complex", "complex(re,im)", "a complex number with real part re, imaginary part im. im defaults to zero." ) );
			_pythonWords.setValue( "continue", 				new AutoCompleteItemVO( VDOMImage.Standard, "continue", "", "" ) );
			_pythonWords.setValue( "copy", 					new AutoCompleteItemVO( VDOMImage.Standard, "copy", "", "Return a duplicate of the context." ) );
			_pythonWords.setValue( "dbhash", 				new AutoCompleteItemVO( VDOMImage.Standard, "dbhash", "", "The dbhash module provides a function to open databases using the BSD db library. This module mirrors the interface of the other Python database modules that provide access to DBM-style databases. The bsddb module is required to use dbhash." ) );
			_pythonWords.setValue( "def", 					new AutoCompleteItemVO( VDOMImage.Standard, "def", "", "" ) );
			_pythonWords.setValue( "del", 					new AutoCompleteItemVO( VDOMImage.Standard, "del", "", "" ) );
			_pythonWords.setValue( "delattr", 				new AutoCompleteItemVO( VDOMImage.Standard, "delattr", "delattr(object, name)", "This is a relative of setattr(). The arguments are an object and a string. The string must be the name of one of the object’s attributes. The function deletes the named attribute, provided the object allows it. For example, delattr(x, 'foobar') is equivalent to del x.foobar." ) );
			_pythonWords.setValue( "dir",	 				new AutoCompleteItemVO( VDOMImage.Standard, "dir", "", "Without arguments, return the list of names in the current local scope. With an argument, attempt to return a list of valid attributes for that object." ) );
			_pythonWords.setValue( "dircmp", 				new AutoCompleteItemVO( VDOMImage.Standard, "dircmp", "", "" ) );
			_pythonWords.setValue( "dis", 					new AutoCompleteItemVO( VDOMImage.Standard, "dis", "", "" ) );
			_pythonWords.setValue( "divmod", 				new AutoCompleteItemVO( VDOMImage.Standard, "divmod", "divmod(a, b)", "Take two (non complex) numbers as arguments and return a pair of numbers consisting of their quotient and remainder when using long division. With mixed operand types, the rules for binary arithmetic operators apply. For plain and long integers, the result is the same as (a // b, a % b). For floating point numbers the result is (q, a % b), where q is usually math.floor(a / b) but may be 1 less than that. In any case q * b + a % b is very close to a, if a % b is non-zero it has the same sign as b, and 0 <= abs(a % b) < abs(b)." ) );
			_pythonWords.setValue( "elif", 					new AutoCompleteItemVO( VDOMImage.Standard, "elif", "", "" ) );
			_pythonWords.setValue( "else", 					new AutoCompleteItemVO( VDOMImage.Standard, "else", "", "" ) );
			_pythonWords.setValue( "EOFError", 				new AutoCompleteItemVO( VDOMImage.Standard, "EOFError", "", "" ) );
			_pythonWords.setValue( "eval", 					new AutoCompleteItemVO( VDOMImage.Standard, "eval", "eval(expression[, globals[, locals]])", "" ) );
			_pythonWords.setValue( "except", 				new AutoCompleteItemVO( VDOMImage.Standard, "except", "", "" ) );
			_pythonWords.setValue( "exec", 					new AutoCompleteItemVO( VDOMImage.Standard, "exec", "", "" ) );
			_pythonWords.setValue( "execfile", 				new AutoCompleteItemVO( VDOMImage.Standard, "execfile", "execfile(filename[, globals[, locals]])", "This function is similar to the <i>exec</i> statement, but parses a file instead of a string. It is different from the import statement in that it does not use the module administration — it reads the file unconditionally and does not create a new module.\n" + 
									"The arguments are a file name and two optional dictionaries. The file is parsed and evaluated as a sequence of Python statements (similarly to a module) using the globals and locals dictionaries as global and local namespace. If provided, locals can be any mapping object.\n" + 
									"If the locals dictionary is omitted it defaults to the globals dictionary. If both dictionaries are omitted, the expression is executed in the environment where execfile() is called. The return value is None." ) );
			
			_pythonWords.setValue( "filter", 				new AutoCompleteItemVO( VDOMImage.Standard, "filter", "filter(function, iterable)", "Construct a list from those elements of iterable for which function returns true. iterable may be either a sequence, a container which supports iteration, or an iterator. If iterable is a string or a tuple, the result also has that type; otherwise it is always a list. If function is None, the identity function is assumed, that is, all elements of iterable that are false are removed.\n" +
									"Note that filter(function, iterable) is equivalent to [item for item in iterable if function(item)] if function is not None and [item for item in iterable if item] if function is None.\n" + 
									"See itertools.ifilter() and itertools.ifilterfalse() for iterator versions of this function, including a variation that filters for elements where the function returns false.") );
			
			_pythonWords.setValue( "finally", 				new AutoCompleteItemVO( VDOMImage.Standard, "finally", "", "" ) );
			_pythonWords.setValue( "find", 					new AutoCompleteItemVO( VDOMImage.Standard, "find", "find(obj[, name][, module][, globs][, extraglobs])", "Return a list of the DocTests that are defined by obj‘s docstring, or by any of its contained objects’ docstrings.\n" +
									"The optional argument name specifies the object’s name; this name will be used to construct names for the returned DocTests. If name is not specified, then obj.__name__ is used.\n" + 
									"The optional parameter module is the module that contains the given object. If the module is not specified or is None, then the test finder will attempt to automatically determine the correct module. The object’s module is used:\n" + 
									"<ul>" +
										"<li>As a default namespace, if globs is not specified. </li>"+
										"<li>To prevent the DocTestFinder from extracting DocTests from objects that are imported from other modules. (Contained objects with modules other than module are ignored.)</li>" + 
										"<li>To find the name of the file containing the object. </li>" + 
										"<li>To help find the line number of the object within its file. </li>" + 
									"</ul>\n" + 
									"If module is False, no attempt to find the module will be made. This is obscure, of use mostly in testing doctest itself: if module is False, or is None but cannot be found automatically, then all objects are considered to belong to the (non-existent) module, so all contained objects will (recursively) be searched for doctests.\n" + 
									"The globals for each DocTest is formed by combining globs and extraglobs (bindings in extraglobs override bindings in globs). A new shallow copy of the globals dictionary is created for each DocTest. If globs is not specified, then it defaults to the module’s __dict__, if specified, or {} otherwise. If extraglobs is not specified, then it defaults to {}.") );
			
			_pythonWords.setValue( "float", 				new AutoCompleteItemVO( VDOMImage.Standard, "float", "", "" ) );
			_pythonWords.setValue( "FloatingPointError", 	new AutoCompleteItemVO( VDOMImage.Standard, "FloatingPointError", "", "Raised when a floating point operation fails. This exception is always defined, but can only be raised when Python is configured with the --with-fpectl option, or the WANT_SIGFPE_HANDLER symbol is defined in the pyconfig.h file." ) );
			_pythonWords.setValue( "fnmatch", 				new AutoCompleteItemVO( VDOMImage.Standard, "fnmatch", "", "" ) );
			_pythonWords.setValue( "for", 					new AutoCompleteItemVO( VDOMImage.Standard, "for", "", "" ) );
			_pythonWords.setValue( "from", 					new AutoCompleteItemVO( VDOMImage.Standard, "from", "", "" ) );
			_pythonWords.setValue( "ftplib", 				new AutoCompleteItemVO( VDOMImage.Standard, "ftplib", "", "This module defines the class FTP and a few related items. The FTP class implements the client side of the FTP protocol. You can use this to write Python programs that perform a variety of automated FTP jobs, such as mirroring other ftp servers. It is also used by the module urllib to handle URLs that use FTP. For more information on FTP (File Transfer Protocol), see Internet RFC 959." ) );
			_pythonWords.setValue( "getattr", 				new AutoCompleteItemVO( VDOMImage.Standard, "getattr", "getattr(object, name[, default]) ", "Return the value of the named attribute of object. name must be a string. If the string is the name of one of the object’s attributes, the result is the value of that attribute. For example, getattr(x, 'foobar') is equivalent to x.foobar. If the named attribute does not exist, default is returned if provided, otherwise AttributeError is raised." ) );
			_pythonWords.setValue( "getopt", 				new AutoCompleteItemVO( VDOMImage.Standard, "getopt", "", "" ) );
			_pythonWords.setValue( "glob", 					new AutoCompleteItemVO( VDOMImage.Standard, "glob", "", "The glob module finds all the pathnames matching a specified pattern according to the rules used by the Unix shell. No tilde expansion is done, but *, ?, and character ranges expressed with [] will be correctly matched. This is done by using the os.listdir() and fnmatch.fnmatch() functions in concert, and not by actually invoking a subshell. (For tilde and shell variable expansion, use os.path.expanduser() and os.path.expandvars().)" ) );
			_pythonWords.setValue( "global", 				new AutoCompleteItemVO( VDOMImage.Standard, "global", "", "" ) );
			_pythonWords.setValue( "globals", 				new AutoCompleteItemVO( VDOMImage.Standard, "globals", "", "" ) );
			_pythonWords.setValue( "grep", 					new AutoCompleteItemVO( VDOMImage.Standard, "grep", "", "" ) );
			_pythonWords.setValue( "group", 				new AutoCompleteItemVO( VDOMImage.Standard, "group", "", "" ) );
			_pythonWords.setValue( "hasattr", 				new AutoCompleteItemVO( VDOMImage.Standard, "hasattr", "hasattr(object, name)", "The arguments are an object and a string. The result is True if the string is the name of one of the object’s attributes, False if not. (This is implemented by calling getattr(object, name) and seeing whether it raises an exception or not.)" ) );
			_pythonWords.setValue( "hash", 					new AutoCompleteItemVO( VDOMImage.Standard, "hash", "hash(object)", "Return the hash value of the object (if it has one). Hash values are integers. They are used to quickly compare dictionary keys during a dictionary lookup. Numeric values that compare equal have the same hash value (even if they are of different types, as is the case for 1 and 1.0)." ) );
			_pythonWords.setValue( "hex", 					new AutoCompleteItemVO( VDOMImage.Standard, "hex", "hex(x)", "Convert an integer number (of any size) to a hexadecimal string. The result is a valid Python expression." ) );
			_pythonWords.setValue( "htmllib", 				new AutoCompleteItemVO( VDOMImage.Standard, "htmllib", "", "" ) );
			_pythonWords.setValue( "httplib", 				new AutoCompleteItemVO( VDOMImage.Standard, "httplib", "", "" ) );
			_pythonWords.setValue( "id", 					new AutoCompleteItemVO( VDOMImage.Standard, "id", "", "" ) );
			_pythonWords.setValue( "if", 					new AutoCompleteItemVO( VDOMImage.Standard, "if", "", "" ) );
			_pythonWords.setValue( "ihooks", 				new AutoCompleteItemVO( VDOMImage.Standard, "ihooks", "", "" ) );
			_pythonWords.setValue( "imghdr", 				new AutoCompleteItemVO( VDOMImage.Standard, "imghdr", "", "" ) );
			_pythonWords.setValue( "import", 				new AutoCompleteItemVO( VDOMImage.Standard, "import", "", "" ) );
			_pythonWords.setValue( "ImportError", 			new AutoCompleteItemVO( VDOMImage.Standard, "ImportError", "", "" ) );
			_pythonWords.setValue( "imputil", 				new AutoCompleteItemVO( VDOMImage.Standard, "imputil", "", "" ) );
			_pythonWords.setValue( "in", 					new AutoCompleteItemVO( VDOMImage.Standard, "in", "", "" ) );
			_pythonWords.setValue( "IndentationError", 		new AutoCompleteItemVO( VDOMImage.Standard, "IndentationError", "", "" ) );
			_pythonWords.setValue( "IndexError", 			new AutoCompleteItemVO( VDOMImage.Standard, "IndexError", "", "" ) );
			_pythonWords.setValue( "input", 				new AutoCompleteItemVO( VDOMImage.Standard, "input", "", "" ) );
			_pythonWords.setValue( "int", 					new AutoCompleteItemVO( VDOMImage.Standard, "int", "", "" ) );
			_pythonWords.setValue( "intern", 				new AutoCompleteItemVO( VDOMImage.Standard, "intern", "", "" ) );
			_pythonWords.setValue( "IOError", 				new AutoCompleteItemVO( VDOMImage.Standard, "IOError", "", "" ) );
			_pythonWords.setValue( "is", 					new AutoCompleteItemVO( VDOMImage.Standard, "is", "", "" ) );
			_pythonWords.setValue( "isinstance", 			new AutoCompleteItemVO( VDOMImage.Standard, "isinstance", "", "" ) );
			_pythonWords.setValue( "issubclass", 			new AutoCompleteItemVO( VDOMImage.Standard, "issubclass", "", "" ) );
			_pythonWords.setValue( "joinfields", 			new AutoCompleteItemVO( VDOMImage.Standard, "joinfields", "", "" ) );
			_pythonWords.setValue( "KeyError", 				new AutoCompleteItemVO( VDOMImage.Standard, "KeyError", "", "" ) );
			_pythonWords.setValue( "KeyboardInterrupt", 	new AutoCompleteItemVO( VDOMImage.Standard, "KeyboardInterrupt", "", "" ) );
			_pythonWords.setValue( "lambda", 				new AutoCompleteItemVO( VDOMImage.Standard, "lambda", "", "" ) );
			_pythonWords.setValue( "len", 					new AutoCompleteItemVO( VDOMImage.Standard, "len", "", "" ) );
			_pythonWords.setValue( "linecache", 			new AutoCompleteItemVO( VDOMImage.Standard, "linecache", "", "" ) );
			_pythonWords.setValue( "list", 					new AutoCompleteItemVO( VDOMImage.Standard, "list", "", "" ) );
			_pythonWords.setValue( "local", 				new AutoCompleteItemVO( VDOMImage.Standard, "local", "", "" ) );
			_pythonWords.setValue( "lockfile", 				new AutoCompleteItemVO( VDOMImage.Standard, "lockfile", "", "" ) );
			_pythonWords.setValue( "long", 					new AutoCompleteItemVO( VDOMImage.Standard, "long", "", "" ) );
			_pythonWords.setValue( "LookupError", 			new AutoCompleteItemVO( VDOMImage.Standard, "LookupError", "", "" ) );
			_pythonWords.setValue( "macpath",	 			new AutoCompleteItemVO( VDOMImage.Standard, "macpath", "", "" ) );
			_pythonWords.setValue( "macurl2path", 			new AutoCompleteItemVO( VDOMImage.Standard, "macurl2path", "", "" ) );
			_pythonWords.setValue( "mailbox", 				new AutoCompleteItemVO( VDOMImage.Standard, "mailbox", "", "" ) );
			_pythonWords.setValue( "mailcap", 				new AutoCompleteItemVO( VDOMImage.Standard, "mailcap", "", "" ) );
			_pythonWords.setValue( "map", 					new AutoCompleteItemVO( VDOMImage.Standard, "map", "", "" ) );
			_pythonWords.setValue( "match", 				new AutoCompleteItemVO( VDOMImage.Standard, "match", "", "" ) );
			_pythonWords.setValue( "math", 					new AutoCompleteItemVO( VDOMImage.Standard, "math", "", "" ) );
			_pythonWords.setValue( "max", 					new AutoCompleteItemVO( VDOMImage.Standard, "max", "", "" ) );
			_pythonWords.setValue( "MemoryError", 			new AutoCompleteItemVO( VDOMImage.Standard, "MemoryError", "", "" ) );
			_pythonWords.setValue( "mimetools", 			new AutoCompleteItemVO( VDOMImage.Standard, "mimetools", "", "" ) );
			_pythonWords.setValue( "Mimewriter", 			new AutoCompleteItemVO( VDOMImage.Standard, "Mimewriter", "", "" ) );
			_pythonWords.setValue( "mimify", 				new AutoCompleteItemVO( VDOMImage.Standard, "mimify", "", "" ) );
			_pythonWords.setValue( "min", 					new AutoCompleteItemVO( VDOMImage.Standard, "min", "", "" ) );
			_pythonWords.setValue( "mutex", 				new AutoCompleteItemVO( VDOMImage.Standard, "mutex", "", "" ) );
			_pythonWords.setValue( "NameError", 			new AutoCompleteItemVO( VDOMImage.Standard, "NameError", "", "" ) );
			_pythonWords.setValue( "newdir", 				new AutoCompleteItemVO( VDOMImage.Standard, "newdir", "", "" ) );
			_pythonWords.setValue( "ni", 					new AutoCompleteItemVO( VDOMImage.Standard, "ni", "", "" ) );
			_pythonWords.setValue( "nntplib", 				new AutoCompleteItemVO( VDOMImage.Standard, "nntplib", "", "" ) );
			_pythonWords.setValue( "None", 					new AutoCompleteItemVO( VDOMImage.Standard, "None", "", "" ) );
			_pythonWords.setValue( "not", 					new AutoCompleteItemVO( VDOMImage.Standard, "not", "", "" ) );
			_pythonWords.setValue( "ntpath", 				new AutoCompleteItemVO( VDOMImage.Standard, "ntpath", "", "" ) );
			_pythonWords.setValue( "nturl2path", 			new AutoCompleteItemVO( VDOMImage.Standard, "nturl2path", "", "" ) );
			_pythonWords.setValue( "oct", 					new AutoCompleteItemVO( VDOMImage.Standard, "oct", "", "" ) );
			_pythonWords.setValue( "open", 					new AutoCompleteItemVO( VDOMImage.Standard, "open", "", "" ) );
			_pythonWords.setValue( "or", 					new AutoCompleteItemVO( VDOMImage.Standard, "or", "", "" ) );
			_pythonWords.setValue( "ord", 					new AutoCompleteItemVO( VDOMImage.Standard, "ord", "", "" ) );
			_pythonWords.setValue( "os", 					new AutoCompleteItemVO( VDOMImage.Standard, "os", "", "" ) );
			_pythonWords.setValue( "ospath", 				new AutoCompleteItemVO( VDOMImage.Standard, "ospath", "", "" ) );
			_pythonWords.setValue( "OverflowError", 		new AutoCompleteItemVO( VDOMImage.Standard, "OverflowError", "", "" ) );
			_pythonWords.setValue( "Para", 					new AutoCompleteItemVO( VDOMImage.Standard, "Para", "", "" ) );
			_pythonWords.setValue( "pass", 					new AutoCompleteItemVO( VDOMImage.Standard, "pass", "", "" ) );
			_pythonWords.setValue( "pdb", 					new AutoCompleteItemVO( VDOMImage.Standard, "pdb", "", "" ) );
			_pythonWords.setValue( "pickle", 				new AutoCompleteItemVO( VDOMImage.Standard, "pickle", "", "" ) );
			_pythonWords.setValue( "pipes", 				new AutoCompleteItemVO( VDOMImage.Standard, "pipes", "", "" ) );
			_pythonWords.setValue( "poly", 					new AutoCompleteItemVO( VDOMImage.Standard, "poly", "", "" ) );
			_pythonWords.setValue( "popen2", 				new AutoCompleteItemVO( VDOMImage.Standard, "popen2", "", "" ) );
			_pythonWords.setValue( "posixfile", 			new AutoCompleteItemVO( VDOMImage.Standard, "posixfile", "", "" ) );
			_pythonWords.setValue( "posixpath", 			new AutoCompleteItemVO( VDOMImage.Standard, "posixpath", "", "" ) );
			_pythonWords.setValue( "pow", 					new AutoCompleteItemVO( VDOMImage.Standard, "pow", "", "" ) );
			_pythonWords.setValue( "print", 				new AutoCompleteItemVO( VDOMImage.Standard, "print", "", "" ) );
			_pythonWords.setValue( "profile", 				new AutoCompleteItemVO( VDOMImage.Standard, "profile", "", "" ) );
			_pythonWords.setValue( "pstats", 				new AutoCompleteItemVO( VDOMImage.Standard, "pstats", "", "" ) );
			_pythonWords.setValue( "pyclbr", 				new AutoCompleteItemVO( VDOMImage.Standard, "pyclbr", "", "" ) );
			_pythonWords.setValue( "pyexpat", 				new AutoCompleteItemVO( VDOMImage.Standard, "pyexpat", "", "" ) );
			_pythonWords.setValue( "Queue", 				new AutoCompleteItemVO( VDOMImage.Standard, "Queue", "", "" ) );
			_pythonWords.setValue( "quopri", 				new AutoCompleteItemVO( VDOMImage.Standard, "quopri", "", "" ) );
			_pythonWords.setValue( "raise", 				new AutoCompleteItemVO( VDOMImage.Standard, "raise", "", "" ) );
			_pythonWords.setValue( "rand", 					new AutoCompleteItemVO( VDOMImage.Standard, "rand", "", "" ) );
			_pythonWords.setValue( "random", 				new AutoCompleteItemVO( VDOMImage.Standard, "random", "", "" ) );
			_pythonWords.setValue( "range", 				new AutoCompleteItemVO( VDOMImage.Standard, "range", "", "" ) );
			_pythonWords.setValue( "raw_input", 			new AutoCompleteItemVO( VDOMImage.Standard, "raw_input", "", "" ) );
			_pythonWords.setValue( "reduce", 				new AutoCompleteItemVO( VDOMImage.Standard, "reduce", "", "" ) );
			_pythonWords.setValue( "response", 				new AutoCompleteItemVO( VDOMImage.Standard, "response", "", "" ) );
			_pythonWords.setValue( "request", 				new AutoCompleteItemVO( VDOMImage.Standard, "request", "", "" ) );
			_pythonWords.setValue( "regex", 				new AutoCompleteItemVO( VDOMImage.Standard, "regex", "", "" ) );
			_pythonWords.setValue( "regsub", 				new AutoCompleteItemVO( VDOMImage.Standard, "regsub", "", "" ) );
			_pythonWords.setValue( "reload", 				new AutoCompleteItemVO( VDOMImage.Standard, "reload", "", "" ) );
			_pythonWords.setValue( "repr", 					new AutoCompleteItemVO( VDOMImage.Standard, "repr", "", "" ) );
			_pythonWords.setValue( "return", 				new AutoCompleteItemVO( VDOMImage.Standard, "return", "", "" ) );
			_pythonWords.setValue( "rfc822", 				new AutoCompleteItemVO( VDOMImage.Standard, "rfc822", "", "" ) );
			_pythonWords.setValue( "round", 				new AutoCompleteItemVO( VDOMImage.Standard, "round", "", "" ) );
			_pythonWords.setValue( "RuntimeError", 			new AutoCompleteItemVO( VDOMImage.Standard, "RuntimeError", "", "" ) );
			_pythonWords.setValue( "sched", 				new AutoCompleteItemVO( VDOMImage.Standard, "sched", "", "" ) );
			_pythonWords.setValue( "search", 				new AutoCompleteItemVO( VDOMImage.Standard, "search", "", "" ) );
			_pythonWords.setValue( "self", 					new AutoCompleteItemVO( VDOMImage.Standard, "self", "", "" ) );
			_pythonWords.setValue( "server", 				new AutoCompleteItemVO( VDOMImage.Standard, "server", "", "" ) );
			_pythonWords.setValue( "session", 				new AutoCompleteItemVO( VDOMImage.Standard, "session", "", "" ) );
			_pythonWords.setValue( "setattr", 				new AutoCompleteItemVO( VDOMImage.Standard, "setattr", "", "" ) );
			_pythonWords.setValue( "setdefault", 			new AutoCompleteItemVO( VDOMImage.Standard, "setdefault", "", "" ) );
			_pythonWords.setValue( "sgmllib", 				new AutoCompleteItemVO( VDOMImage.Standard, "sgmllib", "", "" ) );
			_pythonWords.setValue( "shelve", 				new AutoCompleteItemVO( VDOMImage.Standard, "shelve", "", "" ) );
			_pythonWords.setValue( "SimpleHTTPServer", 		new AutoCompleteItemVO( VDOMImage.Standard, "SimpleHTTPServer", "", "" ) );
			_pythonWords.setValue( "site", 					new AutoCompleteItemVO( VDOMImage.Standard, "site", "", "" ) );
			_pythonWords.setValue( "slice", 				new AutoCompleteItemVO( VDOMImage.Standard, "slice", "", "" ) );
			_pythonWords.setValue( "sndhdr", 				new AutoCompleteItemVO( VDOMImage.Standard, "sndhdr", "", "" ) );
			_pythonWords.setValue( "snmp", 					new AutoCompleteItemVO( VDOMImage.Standard, "snmp", "", "" ) );
			_pythonWords.setValue( "SocketServer", 			new AutoCompleteItemVO( VDOMImage.Standard, "SocketServer", "", "" ) );
			_pythonWords.setValue( "splitfields", 			new AutoCompleteItemVO( VDOMImage.Standard, "splitfields", "", "" ) );
			_pythonWords.setValue( "StandardError", 		new AutoCompleteItemVO( VDOMImage.Standard, "StandardError", "", "" ) );
			_pythonWords.setValue( "staticmethod", 			new AutoCompleteItemVO( VDOMImage.Standard, "staticmethod", "", "" ) );
			_pythonWords.setValue( "str", 					new AutoCompleteItemVO( VDOMImage.Standard, "str", "", "" ) );
			_pythonWords.setValue( "string", 				new AutoCompleteItemVO( VDOMImage.Standard, "string", "", "" ) );
			_pythonWords.setValue( "StringIO", 				new AutoCompleteItemVO( VDOMImage.Standard, "StringIO", "", "" ) );
			_pythonWords.setValue( "struct", 				new AutoCompleteItemVO( VDOMImage.Standard, "struct", "", "" ) );
			_pythonWords.setValue( "SyntaxError", 			new AutoCompleteItemVO( VDOMImage.Standard, "SyntaxError", "", "" ) );
			_pythonWords.setValue( "sys", 					new AutoCompleteItemVO( VDOMImage.Standard, "sys", "", "" ) );
			_pythonWords.setValue( "SystemError", 			new AutoCompleteItemVO( VDOMImage.Standard, "SystemError", "", "" ) );
			_pythonWords.setValue( "SystemExit", 			new AutoCompleteItemVO( VDOMImage.Standard, "SystemExit", "", "" ) );
			_pythonWords.setValue( "TabError", 				new AutoCompleteItemVO( VDOMImage.Standard, "TabError", "", "" ) );
			_pythonWords.setValue( "tb",	 				new AutoCompleteItemVO( VDOMImage.Standard, "tb", "", "" ) );
			_pythonWords.setValue( "tempfile", 				new AutoCompleteItemVO( VDOMImage.Standard, "tempfile", "", "" ) );
			_pythonWords.setValue( "Tkinter", 				new AutoCompleteItemVO( VDOMImage.Standard, "Tkinter", "", "" ) );
			_pythonWords.setValue( "toaiff", 				new AutoCompleteItemVO( VDOMImage.Standard, "toaiff", "", "" ) );
			_pythonWords.setValue( "token", 				new AutoCompleteItemVO( VDOMImage.Standard, "token", "", "" ) );
			_pythonWords.setValue( "tokenize", 				new AutoCompleteItemVO( VDOMImage.Standard, "tokenize", "", "" ) );
			_pythonWords.setValue( "traceback", 			new AutoCompleteItemVO( VDOMImage.Standard, "traceback", "", "" ) );
			_pythonWords.setValue( "try", 					new AutoCompleteItemVO( VDOMImage.Standard, "try", "", "" ) );
			_pythonWords.setValue( "tty", 					new AutoCompleteItemVO( VDOMImage.Standard, "tty", "", "" ) );
			_pythonWords.setValue( "tuple", 				new AutoCompleteItemVO( VDOMImage.Standard, "tuple", "", "" ) );
			_pythonWords.setValue( "type", 					new AutoCompleteItemVO( VDOMImage.Standard, "type", "", "" ) );
			_pythonWords.setValue( "TypeError", 			new AutoCompleteItemVO( VDOMImage.Standard, "TypeError", "", "" ) );
			_pythonWords.setValue( "types", 				new AutoCompleteItemVO( VDOMImage.Standard, "types", "", "" ) );
			_pythonWords.setValue( "tzparse", 				new AutoCompleteItemVO( VDOMImage.Standard, "tzparse", "", "" ) );
			_pythonWords.setValue( "unichr", 				new AutoCompleteItemVO( VDOMImage.Standard, "unichr", "", "" ) );
			_pythonWords.setValue( "unicode", 				new AutoCompleteItemVO( VDOMImage.Standard, "unicode", "", "" ) );
			_pythonWords.setValue( "unicodedata", 			new AutoCompleteItemVO( VDOMImage.Standard, "unicodedata", "", "" ) );
			_pythonWords.setValue( "urllib",				new AutoCompleteItemVO( VDOMImage.Standard, "urllib", "", "" ) );
			_pythonWords.setValue( "urlparse", 				new AutoCompleteItemVO( VDOMImage.Standard, "urlparse", "", "" ) );
			_pythonWords.setValue( "UserDict", 				new AutoCompleteItemVO( VDOMImage.Standard, "UserDict", "", "" ) );
			_pythonWords.setValue( "UserList", 				new AutoCompleteItemVO( VDOMImage.Standard, "UserList", "", "" ) );
			_pythonWords.setValue( "util", 					new AutoCompleteItemVO( VDOMImage.Standard, "util", "", "" ) );
			_pythonWords.setValue( "uu", 					new AutoCompleteItemVO( VDOMImage.Standard, "uu", "", "" ) );
			_pythonWords.setValue( "ValueError", 			new AutoCompleteItemVO( VDOMImage.Standard, "ValueError", "", "" ) );
			_pythonWords.setValue( "vars", 					new AutoCompleteItemVO( VDOMImage.Standard, "vars", "", "" ) );
			_pythonWords.setValue( "wave", 					new AutoCompleteItemVO( VDOMImage.Standard, "wave", "", "" ) );
			_pythonWords.setValue( "webbrowser", 			new AutoCompleteItemVO( VDOMImage.Standard, "webbrowser", "", "" ) );
			_pythonWords.setValue( "whatsound", 			new AutoCompleteItemVO( VDOMImage.Standard, "whatsound", "", "" ) );
			_pythonWords.setValue( "whichdb", 				new AutoCompleteItemVO( VDOMImage.Standard, "whichdb", "", "" ) );
			_pythonWords.setValue( "while", 				new AutoCompleteItemVO( VDOMImage.Standard, "while", "", "" ) );
			_pythonWords.setValue( "whrandom", 				new AutoCompleteItemVO( VDOMImage.Standard, "whrandom", "", "" ) );
			_pythonWords.setValue( "xdrlib", 				new AutoCompleteItemVO( VDOMImage.Standard, "xdrlib", "", "" ) );
			_pythonWords.setValue( "xml", 					new AutoCompleteItemVO( VDOMImage.Standard, "xml", "", "" ) );
			_pythonWords.setValue( "xmlpackage", 			new AutoCompleteItemVO( VDOMImage.Standard, "xmlpackage", "", "" ) );
			_pythonWords.setValue( "xrange", 				new AutoCompleteItemVO( VDOMImage.Standard, "xrange", "", "" ) );
			_pythonWords.setValue( "ZeroDivisionError", 	new AutoCompleteItemVO( VDOMImage.Standard, "ZeroDivisionError", "", "" ) );
			_pythonWords.setValue( "zip", 					new AutoCompleteItemVO( VDOMImage.Standard, "zip", "", "" ) );
			_pythonWords.setValue( "zmod", 					new AutoCompleteItemVO( VDOMImage.Standard, "zmod", "", "" ) );

			var f : Field;
			var param : Field;
			
			if ( !_pythonFields )
			{
				_pythonFields = new HashList();
				
				//abs(x)
				setField("abs", new Array("x") );
				
				//apply(function, args[, keywords])
				setField("apply", new Array("function", "args[, keywords]") );
				
				//chr(i)
				setField("chr", new Array("i") );
				
				//cmp(x, y)
				setField("cmp", new Array("x", "y") );
				
				//coerce(x, y)
				setField("coerce", new Array("x", "y") );
				
				//compile(source, filename, mode[, flags[, dont_inherit]])
				setField("compile", new Array("source", "filename", "mode[", "flags[", "dont_inherit]]") );
				
				//complex(re,im)
				setField("complex", new Array("re", "im") );
				
				//delattr(object, name)
				setField("delattr", new Array("object", "name") );
				
				//divmod(a, b)
				setField("divmod", new Array("a", "b") );
				
				//eval(expression[, globals[, locals]])
				setField("eval", new Array("expression[", "globals[", "locals]]") );
				
				//execfile(filename[, globals[, locals]])
				setField("execfile", new Array("filename[", "globals[", "locals]]") );
				
				//filter(function, iterable)
				setField("filter", new Array("function", "iterable") );
				
				//find(obj[, name][, module][, globs][, extraglobs])
				setField("find", new Array("obj[", "name][", "module][", "globs][", "extraglobs]") );
				
				//hasattr(object, name)
				setField("hasattr", new Array("object", "name") );
				
				//hash(object)
				setField("hash", new Array("object") );
				
				//hex(x)
				setField("hex", new Array("x") );
			}
			
			function setField( name : String, params : Array ) : void
			{
				f = new Field( "def", 0 , name );
				var paramName : String;
				
				for each( paramName in params )
				{
					param = new Field("var", 0 , paramName );
					f.params.setValue( paramName, param );
				}
				
				_pythonFields.setValue( name, f );
			}
		}
	}
}