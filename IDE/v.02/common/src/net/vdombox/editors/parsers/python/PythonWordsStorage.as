package net.vdombox.editors.parsers.python
{
	import flash.net.dns.AAAARecord;
	
	import mx.utils.ObjectUtil;
	
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashList;

	public class PythonWordsStorage
	{
		public function PythonWordsStorage()
		{
		}
		
		
		
		private static var _pythonWords : Vector.<AutoCompleteItemVO>;
		private static var _pythonFields : HashList;
		
		public static function get pythonWords():Vector.<AutoCompleteItemVO>
		{
			if ( !_pythonWords )
				init();
				
			var vector : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
			vector.concat( _pythonWords );
			
			return vector;
		}

		public static function init() : void
		{
			if ( !_pythonWords )
			{
				_pythonWords = new Vector.<AutoCompleteItemVO>();
				
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "abs", "abs(x)", "Return the absolute value of a number. The argument may be a plain or long integer or a floating point number. If the argument is a complex number, its magnitude is returned." ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "and", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "application", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "apply", "apply(function, args[, keywords])", "The function argument must be a callable object (a user-defined or built-in function or method, or a class object) and the args argument must be a sequence. The function is called with args as the argument list; the number of arguments is the length of the tuple. If the optional keywords argument is present, it must be a dictionary whose keys are strings. It specifies keyword arguments to be added to the end of the argument list. Calling apply() is different from just calling function(args), since in that case there is always exactly one argument. The use of apply() is equivalent to function(*args, **keywords)." ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ArithmeticError", "", "The base class for those built-in exceptions that are raised for various arithmetic errors: OverflowError, ZeroDivisionError, FloatingPointError." ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "array", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "assert", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "AssertionError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "AST", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "atexit", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "AttributeError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "BaseHTTPServer", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Bastion", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "break", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "callable", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "CGIHTTPServer", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "chr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "class", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "cmd", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "cmp", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "codecs", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "coerce", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "commands", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "compile", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "compileall", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Complex", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "complex", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "continue", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "copy", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dbhash", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "def", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "del", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "delattr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dir", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dircmp", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dis", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "divmod", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dospath", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dbhash", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "dumbdbm", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "elif", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "else", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "emacs", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "EOFError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "eval", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "except", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Exception", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "exec", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "execfile", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "filter", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "finally", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "find", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "float", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "FloatingPointError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "fmt", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "fnmatch", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "for", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "from", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ftplib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "getattr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "getopt", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "glob", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "global", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "globals", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "gopherlib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "grep", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "group", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "hasattr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "hash", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "hex", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "htmllib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "httplib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "id", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "if", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ihooks", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "imghdr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "import", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ImportError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "imputil", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "in", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "IndentationError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "IndexError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "input", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "int", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "intern", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "IOError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "is", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "isinstance", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "issubclass", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "joinfields", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "KeyError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "KeyboardInterrupt", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "lambda", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "len", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "linecache", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "list", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "local", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "lockfile", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "long", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "LookupError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "macpath", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "macurl2path", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "mailbox", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "mailcap", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "map", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "match", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "math", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "max", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "MemoryError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "mimetools", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Mimewriter", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "mimify", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "min", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "mutex", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "NameError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "newdir", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ni", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "nntplib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "None", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "not", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ntpath", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "nturl2path", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "oct", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "open", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "or", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ord", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "os", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ospath", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "OverflowError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Para", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pass", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pdb", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pickle", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pipes", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "poly", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "popen2", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "posixfile", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "posixpath", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pow", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "print", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "profile", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pstats", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pyclbr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "pyexpat", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Queue", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "quopri", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "raise", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "rand", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "random", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "range", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "raw_input", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "reduce", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "response", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "request", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "regex", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "regsub", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "reload", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "repr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "return", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "rfc822", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "round", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "RuntimeError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "sched", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "search", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "self", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "server", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "session", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "setattr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "setdefault", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "sgmllib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "shelve", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "SimpleHTTPServer", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "site", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "slice", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "sndhdr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "snmp", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "SocketServer", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "splitfields", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "StandardError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "str", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "string", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "StringIO", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "struct", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "SyntaxError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "sys", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "SystemError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "SystemExit", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "TabError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "tb", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "tempfile", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "Tkinter", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "toaiff", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "token", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "tokenize", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "traceback", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "try", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "tty", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "tuple", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "type", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "TypeError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "types", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "tzparse", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "unichr", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "unicode", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "unicodedata", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "urllib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "urlparse", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "UserDict", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "UserList", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "util", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "uu", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ValueError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "vars", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "wave", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "webbrowser", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "whatsound", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "whichdb", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "while", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "whrandom", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "xdrlib", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "xml", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "xmlpackage", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "xrange", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "ZeroDivisionError", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "zip", "", "" ) );
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, "zmod", "", "" ) );
			}
			var f : Field;
			var param : Field;
			
			if ( !_pythonFields )
			{
				_pythonFields = new HashList();
				
				//abs
				f = new Field( "def", 0, "abs" );
				param = new Field ( "var", 0 , "x" );
				f.params.setValue( param.name, param );
				
				_pythonFields.setValue( f.name, f );
				
				//apply
				f = new Field( "def", 0, "apply" );
				param = new Field ( "var", 0 , "function" );
				f.params.setValue( param.name, param );
				param = new Field ( "var", 0 , "args[, keywords]" );
				f.params.setValue( param.name, param );
				
				_pythonFields.setValue( f.name, f );
			}
			
			
		}
	}
}