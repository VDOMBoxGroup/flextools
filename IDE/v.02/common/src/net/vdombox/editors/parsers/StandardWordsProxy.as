package net.vdombox.editors.parsers
{
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashMap;

	public class StandardWordsProxy
	{
		public function StandardWordsProxy()
		{
		}
		
		private static var _autoCompleteItemVOList : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
		
		private static var _vscriptWordsString : Vector.<String> = new <String>["And", "AndAlso", "application", "Array", "As", "AsJSON", "Binary", "Boolean", "ByVal", "ByRef", "Case", "Catch", "Chr", "Class", "Connection", "Const", "cstr", "Date", "Dictionary", "Dim", "Do", "Double", "Each", "Else", "ElseIf", "Empty", "End", "Eqv", "Erase", "Error", "Exit", "False", "For", "Function", "Generic", "Get", "Hex", "If", "In", "inherits", "Integer", "Imp", "Is", "IsFalse", "IsNot", "IsTrue", "Let", "Like", "Loop", "Match", "Matches", "Mismatch", "Mod", "New", "Next", "Not", "Nothing", "Null", "Oct", "Or", "OrElse", "Preserve", "Print", "Proxy", "Randomize", "ReDim", "RegExp", "request", "Rem", "replace", "response", "Select", "server", "Session", "Set", "Sgn", "Step", "String", "Sub", "Then", "this", "To", "ToJSON", "True", "Try", "UBound", "Until", "Use", "VdomDbConnection", "VDOMDBRecordSet", "VDOMDBRow", "VDOMImaging", "Wend", "While", "WHOLEConnection", "WHOLEError", "WHOLEConnectionError", "WHOLENoConnectionError", "WHOLERemoteCallError", "WHOLEIncorrectResponse", "WHOLENoAPIError", "WHOLENoApplication", "With", "XMLDocument", "XMLNode", "Xor"  ];
		
		private static var _vscriptWords : Vector.<AutoCompleteItemVO>;
		private static var _vscriptTypeWords : Vector.<AutoCompleteItemVO>;
		
		private static var _pythonWordsString : Vector.<String> = new <String>["abs", "and", "apply", "ArithmeticError", "array", "assert", "AssertionError", "AST", "atexit", "AttributeError", "BaseHTTPServer", "Bastion", "break", "callable", "CGIHTTPServer", "chr", "class", "cmd", "cmp", "codecs", "coerce", "commands", "compile", "compileall", "Complex", "complex", "continue", "copy", "dbhash", "def", "del", "delattr", "dir", "dircmp", "dis", "divmod", "dospath", "dumbdbm", "elif", "else", "emacs", "EOFError", "eval", "except", "Exception", "exec", "execfile", "filter", "finally", "find", "float", "FloatingPointError", "fmt", "fnmatch", "for", "from", "ftplib", "getattr", "getopt", "glob", "global", "globals", "gopherlib", "grep", "group", "hasattr", "hash", "hex", "htmllib", "httplib", "id", "if", "ihooks", "imghdr", "import", "ImportError","imputil", "in", "IndentationError", "IndexError", "input", "int", "intern", "IOError", "is", "isinstance", "issubclass", "joinfields", "KeyError", "KeyboardInterrupt", "lambda", "len", "linecache", "list", "local", "lockfile", "long", "LookupError", "macpath", "macurl2path", "mailbox", "mailcap", "map", "match", "math", "max", "MemoryError", "mimetools", "Mimewriter", "mimify", "min", "mutex", "NameError", "newdir", "ni", "nntplib", "None", "not", "ntpath", "nturl2path", "oct", "open", "or", "ord", "os", "ospath", "OverflowError", "Para", "pass", "pdb", "pickle", "pipes", "poly", "popen2", "posixfile", "posixpath", "pow", "print", "profile", "pstats", "pyclbr", "pyexpat", "Queue", "quopri", "raise", "rand", "random", "range", "raw_input", "reduce", "response", "request", "regex", "regsub", "reload", "repr", "return", "rfc822", "round", "RuntimeError", "sched", "search", "self", "session", "setattr", "setdefault", "sgmllib", "shelve", "SimpleHTTPServer", "site", "slice", "sndhdr", "snmp", "SocketServer", "splitfields", "StandardError", "str", "string", "StringIO", "struct", "SyntaxError", "sys", "SystemError", "SystemExit", "TabError", "tb", "tempfile", "Tkinter", "toaiff", "token", "tokenize", "traceback", "try", "tty", "tuple", "type", "TypeError", "types", "tzparse", "unichr", "unicode", "unicodedata", "urllib", "urlparse", "UserDict", "UserList", "util", "uu", "ValueError", "vars", "wave", "webbrowser", "whatsound", "whichdb", "while", "whrandom", "xdrlib", "xml", "xmlpackage", "xrange", "ZeroDivisionError",  "zip", "zmod"];
		private static var _pythonWords : Vector.<AutoCompleteItemVO>;
		
		public static function getAutoCompleteItemVOByField( f : Field, imports : Boolean = false ) : AutoCompleteItemVO
		{
			var icon : Class;
			
			switch(f.fieldType)
			{
				case "var":
				{
					icon = imports ? VDOMImage.Variable_Import : VDOMImage.Variable;
					
					break;
				}
					
				case "def":
				{
					icon = imports ? VDOMImage.Function_Import : VDOMImage.Function_;
					
					break;
				}
					
				case "class":
				{
					icon = imports ? VDOMImage.Class_Import : VDOMImage.Class_;
					
					break;
				}
					
				default:
				{
					icon = VDOMImage.Standard;
				}
			}
			
			return new AutoCompleteItemVO( icon, f.name );
			
		}
		
		public static function get vscriptWords() : Vector.<AutoCompleteItemVO>
		{
			_vscriptWords = new Vector.<AutoCompleteItemVO>();
			
			for each( var item : String in _vscriptWordsString )
			{
				_vscriptWords.push( new AutoCompleteItemVO( VDOMImage.Standard, item ) );
			}
			
			return _vscriptWords;
		}
		
		public static function get vscriptTypeWords() : Vector.<AutoCompleteItemVO>
		{
			_vscriptTypeWords = new Vector.<AutoCompleteItemVO>();
			var a : Vector.<String> = new <String>["Array", "Binary", "Boolean", "Date", "Dictionary", "Double", "Error", "Integer" ];
			
			for each( var item : String in a )
			{
				_vscriptTypeWords.push( new AutoCompleteItemVO( VDOMImage.Standard, item ) );
			}
			
			return _vscriptTypeWords;
		}
		
		public static function get pythonWords() : Vector.<AutoCompleteItemVO>
		{
			_pythonWords = new Vector.<AutoCompleteItemVO>();
			
			for each( var item : String in _pythonWordsString )
			{
				_pythonWords.push( new AutoCompleteItemVO( VDOMImage.Standard, item ) );
			}
			
			return _pythonWords;
		}
		
		public static function get standardVScriptObjects() : HashMap
		{
			var a : HashMap = new HashMap();
			
			
			//RegExp
			var field : Field = new Field( "class", 0, "RegExp" );
			field.members.setValue( "ignorecase", new Field( "var", 0 , "IgnoreCase" ) );
			field.members.setValue( "global", new Field( "var", 0 , "Global" ) );
			field.members.setValue( "test", new Field( "def", 0 , "Test" ) );
			field.members.setValue( "replace", new Field( "def", 0 , "Replace" ) );
			field.members.setValue( "execute", new Field( "def", 0 , "Execute" ) );
			a.setValue("regexp", field );
			
			
			//Connection
			field = new Field( "class", 0, "Connection" );
			field.members.setValue( "encoding", new Field( "var", 0 , "Encoding" ) );
			field.members.setValue( "proxy", new Field( "var", 0 , "Proxy" ) );
			field.members.setValue( "isconnected", new Field( "var", 0 , "IsConnected" ) );
			field.members.setValue( "open", new Field( "def", 0 , "Open" ) );
			field.members.setValue( "read", new Field( "def", 0 , "Read" ) );
			field.members.setValue( "write", new Field( "def", 0 , "Write" ) );
			field.members.setValue( "close", new Field( "def", 0 , "Close" ) );
			a.setValue("connection", field );
			
			
			//VDOMDBConnection
			field = new Field( "class", 0, "VDOMDBConnection" );
			field.members.setValue( "close", new Field( "def", 0 , "Close" ) );
			field.members.setValue( "execute", new Field( "def", 0 , "Execute" ) );
			field.members.setValue( "open", new Field( "def", 0 , "Open" ) );
			field.members.setValue( "query", new Field( "def", 0 , "Query" ) );
			
			a.setValue("vdomdbconnection", field );
			
			
			return a;
		}
		
		
	}
}