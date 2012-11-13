package net.vdombox.editors.parsers
{
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.python.PythonWordsStorage;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashMap;

	public class StandardWordsProxy
	{
		public function StandardWordsProxy()
		{
		}
		
		private static var _autoCompleteItemVOList : Vector.<AutoCompleteItemVO> = new Vector.<AutoCompleteItemVO>();
		
		private static var _vscriptWordsString : Vector.<String> = new <String>["And", "AndAlso", "application", "Array", "As", "AsJSON", "Binary", "Boolean", "ByVal", "ByRef", "Case", "Catch", "Chr", "Class", "Connection", "Const", "cstr", "Date", "Dictionary", "Dim", "Do", "Double", "Each", "Else", "ElseIf", "Empty", "End", "Eqv", "Erase", "Error", "Exit", "False", "Finally", "For", "Function", "Generic", "Get", "Hex", "If", "In", "inherits", "Integer", "Imp", "Is", "IsFalse", "IsNot", "IsTrue", "Let", "Like", "Loop", "Match", "Matches", "Mismatch", "Mod", "New", "Next", "Not", "Nothing", "Null", "Oct", "Or", "OrElse", "Preserve", "Print", "Proxy", "Randomize", "ReDim", "RegExp", "request", "Rem", "replace", "response", "Select", "server", "Session", "Set", "Sgn", "Step", "String", "Sub", "Then", "this", "To", "ToJSON", "True", "Try", "UBound", "Until", "Use", "VdomDbConnection", "VDOMDBRecordSet", "VDOMDBRow", "VDOMImaging", "Wend", "While", "WHOLEConnection", "WHOLEError", "WHOLEConnectionError", "WHOLENoConnectionError", "WHOLERemoteCallError", "WHOLEIncorrectResponse", "WHOLENoAPIError", "WHOLENoApplication", "With", "XMLAttribute", "XMLDocument", "XMLDomstirngSizeError", "XMLElement", "XMLError", "XMLHierarchyRequestError", "XMLIndexSizeError", "XMLInuseAttributeError", "XMLInvalidAccessError", "XMLInvalidCharacterError", "XMLInvalidModificationError", "XMLInvalidStateError", "XMLNamespaceError", "XMLNoDataAllowedError", "XMLNotFoundError", "XMLNotSupportedError", "XMLNode", "XMLSyntaxError", "XMLWrongDocumentError", "Xor"  ];
		
		private static var _vscriptWords : Vector.<AutoCompleteItemVO>;
		private static var _vscriptTypeWords : Vector.<AutoCompleteItemVO>;
		
		private static var _pythonWords : Vector.<AutoCompleteItemVO>;
		
		private static var _standardVScriptObjects : HashMap;
		private static var _standardPythonObjects : HashMap;
		
		public static function getTranscriptionByField( f : Field ) : String
		{
			var transcription : String;
			
			switch(f.fieldType)
			{
				case "var":
				{
					transcription = f.name;
					
					break;
				}
					
				case "class":
				{
				}
					
				case "def":
				{
					transcription = f.name;
					
					var params : Array = f.params.toArray();
					
					if ( params.length > 0 )
					{
						transcription += "(";
						for each ( var f2 : Field in params )
						{
							transcription += f2.defaultValue != "" ? ( f2.name + " = " + f2.defaultValue + ", " ) : ( f2.name + ", " );
						}
						transcription = transcription.slice( 0, transcription.length - 2);
						
						transcription += ")";
					}
					
					break;
				}
					
				default:
				{
					transcription = f.name;
				}
			}
			
			return transcription;
		}
		
		public static function getAutoCompleteItemVOByField( f : Field, imports : Boolean = false ) : AutoCompleteItemVO
		{
			var icon : Class;
			var transcription : String = getTranscriptionByField( f );
			var description : String = f.description;
			
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
			
			return new AutoCompleteItemVO( icon, f.name, transcription, description );
			
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
			return PythonWordsStorage.pythonWordsAutocomplete;
		}
		
		public static function getAutocompleteItemVOByName( name : String ) : AutoCompleteItemVO
		{
			return PythonWordsStorage.getAutocompleteItemVOByName( name );
		}
		
		public static function get standardVScriptObjects() : HashMap
		{
			if ( _standardVScriptObjects )
				return _standardVScriptObjects;
			
			_standardVScriptObjects = new HashMap();
			
			//RegExp
			var field : Field = new Field( "class", 0, "RegExp" );
			field.members.setValue( "pattern", new Field( "var", 0 , "Pattern" ) );
			field.members.setValue( "ignorecase", new Field( "var", 0 , "IgnoreCase" ) );
			field.members.setValue( "global", new Field( "var", 0 , "Global" ) );
			field.members.setValue( "test", new Field( "def", 0 , "Test" ) );
			field.members.setValue( "replace", new Field( "def", 0 , "Replace" ) );
			field.members.setValue( "execute", new Field( "def", 0 , "Execute" ) );
			_standardVScriptObjects.setValue("regexp", field );
			
			
			//Connection
			field = new Field( "class", 0, "Connection" );
			field.members.setValue( "encoding", new Field( "var", 0 , "Encoding" ) );
			field.members.setValue( "proxy", new Field( "var", 0 , "Proxy" ) );
			field.members.setValue( "isconnected", new Field( "var", 0 , "IsConnected" ) );
			field.members.setValue( "open", new Field( "def", 0 , "Open" ) );
			field.members.setValue( "read", new Field( "def", 0 , "Read" ) );
			field.members.setValue( "write", new Field( "def", 0 , "Write" ) );
			field.members.setValue( "close", new Field( "def", 0 , "Close" ) );
			_standardVScriptObjects.setValue("connection", field );
			
			
			//VDOMDBConnection
			field = new Field( "class", 0, "VDOMDBConnection" );
			field.members.setValue( "close", new Field( "def", 0 , "Close" ) );
			field.members.setValue( "execute", new Field( "def", 0 , "Execute" ) );
			field.members.setValue( "open", new Field( "def", 0 , "Open" ) );
			field.members.setValue( "query", new Field( "def", 0 , "Query" ) );
			
			_standardVScriptObjects.setValue("vdomdbconnection", field );
			
			
			
			//VDOMImaging
			field = new Field( "class", 0, "VDOMImaging" );
			field.members.setValue( "width", new Field( "var", 0 , "Width" ) );
			field.members.setValue( "height", new Field( "var", 0 , "Height" ) );
			field.members.setValue( "load", new Field( "def", 0 , "Load" ) );
			field.members.setValue( "createfont", new Field( "def", 0 , "CreateFont" ) );
			field.members.setValue( "writetext", new Field( "def", 0 , "WriteText" ) );
			field.members.setValue( "crop", new Field( "def", 0 , "Crop" ) );
			field.members.setValue( "thumbnail", new Field( "def", 0 , "Thumbnail" ) );
			field.members.setValue( "savetemporary", new Field( "def", 0 , "SaveTemporary" ) );
			field.members.setValue( "save", new Field( "def", 0 , "Save" ) );
			
			_standardVScriptObjects.setValue("vdomimaging", field );
			
			
			return _standardVScriptObjects;
		}
		
		public static function get standardPythonObjects() : HashMap
		{
			if ( _standardPythonObjects )
				return _standardPythonObjects;
			
			_standardPythonObjects = new HashMap();
			
			//request
			var field : Field = new Field( "class", 0, "request" );
			
			field.members.setValue( "container", new Field( "var", 0 , "container" ) );
			field.members.setValue( "environment", new Field( "var", 0 , "environment" ) );
			field.members.setValue( "headers", new Field( "var", 0 , "headers" ) );
			field.members.setValue( "client", new Field( "var", 0 , "client" ) );
			field.members.setValue( "server", new Field( "var", 0 , "server" ) );
			field.members.setValue( "protocol", new Field( "var", 0 , "protocol" ) );
			field.members.setValue( "cookies", new Field( "var", 0 , "cookies" ) );
			field.members.setValue( "protocol", new Field( "var", 0 , "protocol" ) );
			
			field.members.setValue( "arguments", new Field( "def", 0 , "arguments" ) );
			field.members.setValue( "shared_variables", new Field( "def", 0 , "shared_variables" ) );
			
			_standardPythonObjects.setValue("request", field );
			
			
			//response
			field = new Field( "class", 0, "response" );
			
			field.members.setValue( "headers", new Field( "var", 0 , "headers" ) );
			field.members.setValue( "binary", new Field( "var", 0 , "binary" ) );
			field.members.setValue( "nocache", new Field( "var", 0 , "nocache" ) );
			field.members.setValue( "cookies", new Field( "var", 0 , "cookies" ) );
			
			field.members.setValue( "write", new Field( "def", 0 , "write" ) );
			field.members.setValue( "send_file", new Field( "def", 0 , "send_file" ) );
			field.members.setValue( "redirect", new Field( "def", 0 , "redirect" ) );
			field.members.setValue( "terminate", new Field( "def", 0 , "terminate" ) );
			
			_standardPythonObjects.setValue("response", field );
			
			
			//session
			field = new Field( "class", 0, "session" );
			
			field.members.setValue( "id", new Field( "var", 0 , "id" ) );
			
			field.members.setValue( "keys", new Field( "def", 0 , "keys" ) );
			field.members.setValue( "get", new Field( "def", 0 , "get" ) );
			
			_standardPythonObjects.setValue("session", field );
			
			
			//application
			field = new Field( "class", 0, "application" );
			
			field.members.setValue( "id", new Field( "var", 0 , "id" ) );
			field.members.setValue( "name", new Field( "var", 0 , "name" ) );
			field.members.setValue( "structure", new Field( "var", 0 , "structure" ) );
			field.members.setValue( "storage", new Field( "var", 0 , "storage" ) );
			field.members.setValue( "objects", new Field( "var", 0 , "objects" ) );
			field.members.setValue( "databases", new Field( "var", 0 , "databases" ) );
			field.members.setValue( "resources", new Field( "var", 0 , "resources" ) );
			
			_standardPythonObjects.setValue("application", field );
			
			//server
			field = new Field( "class", 0, "server" );
			
			field.members.setValue( "version", new Field( "var", 0 , "version" ) );
			field.members.setValue( "mailer", new Field( "var", 0 , "mailer" ) );
			field.members.setValue( "log", new Field( "var", 0 , "log" ) );
			field.members.setValue( "security", new Field( "var", 0 , "security" ) );
			
			_standardPythonObjects.setValue("server", field );
			
			
			return _standardPythonObjects;
		}
		
		
	}
}