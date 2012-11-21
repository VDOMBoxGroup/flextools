package net.vdombox.editors.parsers.vscript
{
	import net.vdombox.editors.parsers.AutoCompleteItemVO;
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.ide.common.view.components.VDOMImage;
	
	import ro.victordramba.util.HashList;

	public class VScriptWordsStorage
	{
		public function VScriptWordsStorage()
		{
		}
		
		private static var _vscriptWordsString : Vector.<String> = new <String>["Abs", "And", "AndAlso", "application", "Array", "As", "AsJSON", "Atn", "Binary", "Boolean", "ByVal", "ByRef", "Case", "Catch", "CBool", "CByte", "CDate", "CDbl", "Chr", "CInt", "Class", "CLng", "Connection", "Const", "Cos", "CSng", "CStr", "Date", "DateAdd", "Dictionary", "Dim", "Do", "Double", "Each", "Else", "ElseIf", "Empty", "End", "Eqv", "Erase", "Error", "Exit", "Exp", "False", "Finally", "Fix", "For", "Function", "Generic", "Get", "Hex", "If", "In", "inherits", "Int", "Integer", "Imp", "Is", "IsDate", "IsFalse", "IsNot", "IsTrue", "Let", "Like", "Log", "Loop", "Match", "Matches", "Mid", "Mismatch", "Mod", "New", "Next", "Not", "Nothing", "Now", "Null", "Oct", "Or", "OrElse", "Preserve", "Print", "Proxy", "Randomize", "ReDim", "RegExp", "request", "Rem", "replace", "response", "Rnd", "Select", "server", "Session", "Set", "Sgn", "Sin", "Sqr", "Step", "String", "Sub", "Tan", "Then", "this", "Time", "Timer", "To", "ToJSON", "True", "Try", "UBound", "Until", "Use", "VdomDbConnection", "VDOMDBRecordSet", "VDOMDBRow", "VDOMImaging", "Wend", "While", "WHOLEConnection", "WHOLEError", "WHOLEConnectionError", "WHOLENoConnectionError", "WHOLERemoteCallError", "WHOLEIncorrectResponse", "WHOLENoAPIError", "WHOLENoApplication", "With", "XMLAttribute", "XMLDocument", "XMLDomstirngSizeError", "XMLElement", "XMLError", "XMLHierarchyRequestError", "XMLIndexSizeError", "XMLInuseAttributeError", "XMLInvalidAccessError", "XMLInvalidCharacterError", "XMLInvalidModificationError", "XMLInvalidStateError", "XMLNamespaceError", "XMLNoDataAllowedError", "XMLNotFoundError", "XMLNotSupportedError", "XMLNode", "XMLSyntaxError", "XMLWrongDocumentError", "Xor"  ];
		
		private static var _vscriptWordsAutocomplete : Vector.<AutoCompleteItemVO>;
		private static var _vscriptWords : HashList;
		private static var _vscriptFields : HashList;
		
		public static function get vscriptWordsAutocomplete():Vector.<AutoCompleteItemVO>
		{
			_vscriptWordsAutocomplete = new Vector.<AutoCompleteItemVO>();
			
			for each( var item : String in _vscriptWordsString )
			{
				_vscriptWordsAutocomplete.push( new AutoCompleteItemVO( VDOMImage.Standard, item ) );
			}
			
			return _vscriptWordsAutocomplete;
		}
		
		public static function getAutocompleteItemVOByName( name : String ) : AutoCompleteItemVO
		{
			if ( !_vscriptWords )
				init();
			
			return _vscriptWords.getValue( name );
			
		}
		
		public static function getFieldByName( name : String ) : Field
		{
			if ( !_vscriptFields )
				init();
			
			return _vscriptFields.getValue( name );
			
		}
		
		private static function init() : void
		{
			_vscriptWords
			_vscriptWords = new HashList();
			
			_vscriptWords.setValue( "Abs", 					new AutoCompleteItemVO( VDOMImage.Standard, "Abs", "Abs(number)", "Returns the absolute value of a specified number" ) );
			_vscriptWords.setValue( "And", 					new AutoCompleteItemVO( VDOMImage.Standard, "And", "", "" ) );
			_vscriptWords.setValue( "AndAlso", 				new AutoCompleteItemVO( VDOMImage.Standard, "AndAlso", "", "" ) );
			_vscriptWords.setValue( "application", 			new AutoCompleteItemVO( VDOMImage.Standard, "application", "", "" ) );
			_vscriptWords.setValue( "Array", 				new AutoCompleteItemVO( VDOMImage.Standard, "Array", "", "" ) );
			_vscriptWords.setValue( "As", 					new AutoCompleteItemVO( VDOMImage.Standard, "As", "", "" ) );
			_vscriptWords.setValue( "AsJSON", 				new AutoCompleteItemVO( VDOMImage.Standard, "AsJSON", "", "" ) );
			_vscriptWords.setValue( "Atn", 					new AutoCompleteItemVO( VDOMImage.Standard, "Atn", "Atn(number)", "Returns the arctangent of a specified number" ) );
			_vscriptWords.setValue( "Binary", 				new AutoCompleteItemVO( VDOMImage.Standard, "Binary", "", "" ) );
			_vscriptWords.setValue( "Boolean", 				new AutoCompleteItemVO( VDOMImage.Standard, "Boolean", "", "" ) );
			_vscriptWords.setValue( "ByVal", 				new AutoCompleteItemVO( VDOMImage.Standard, "ByVal", "", "" ) );
			_vscriptWords.setValue( "ByRef", 				new AutoCompleteItemVO( VDOMImage.Standard, "ByRef", "", "" ) );
			_vscriptWords.setValue( "Case", 				new AutoCompleteItemVO( VDOMImage.Standard, "Case", "", "" ) );
			_vscriptWords.setValue( "Catch", 				new AutoCompleteItemVO( VDOMImage.Standard, "Catch", "", "" ) );
			_vscriptWords.setValue( "CBool", 				new AutoCompleteItemVO( VDOMImage.Standard, "CBool", "CBool(expression)", "Converts an expression to a variant of subtype Boolean" ) );
			
			_vscriptWords.setValue( "CByte", 				new AutoCompleteItemVO( VDOMImage.Standard, "CByte", "CByte(expression) ", "Converts an expression to a variant of subtype Byte\n"+
										"The expression must be a number between 0 and 255") );
			
			_vscriptWords.setValue( "CDate", 				new AutoCompleteItemVO( VDOMImage.Standard, "CDate", "CDate(date)", "Converts a valid date and time expression to the variant of subtype Date" ) );
			
			_vscriptWords.setValue( "CDbl", 				new AutoCompleteItemVO( VDOMImage.Standard, "CDbl", "CDbl(expression) ", "Converts an expression to a variant of subtype Double\n"+
										"The expression must be a numeric value.") );
			
			_vscriptWords.setValue( "Chr", 					new AutoCompleteItemVO( VDOMImage.Standard, "Chr", "Chr(charcode)", "Converts the specified ANSI code to a character" ) );
			_vscriptWords.setValue( "CInt", 				new AutoCompleteItemVO( VDOMImage.Standard, "CInt", "CInt(expression) ", "Converts an expression to a variant of subtype Integer\n+" +
										"<b>Note</b> The value must be a number between -32768 and 32767.") );
			
			_vscriptWords.setValue( "Class", 				new AutoCompleteItemVO( VDOMImage.Standard, "Class", "", "" ) );
			_vscriptWords.setValue( "CLng", 				new AutoCompleteItemVO( VDOMImage.Standard, "CLng", "CLng(expression) ", " Converts an expression to a variant of subtype Long\n+" +
				"<b>Note</b> The value must be a number between -2147483648 and 2147483647.") );
			
			_vscriptWords.setValue( "Connection", 			new AutoCompleteItemVO( VDOMImage.Standard, "Connection", "", "" ) );
			_vscriptWords.setValue( "Const", 				new AutoCompleteItemVO( VDOMImage.Standard, "Const", "", "" ) );
			_vscriptWords.setValue( "Cos", 					new AutoCompleteItemVO( VDOMImage.Standard, "Cos", "Cos(number)", "Returns the cosine of a specified number (angle)" ) );
			_vscriptWords.setValue( "CSng", 				new AutoCompleteItemVO( VDOMImage.Standard, "CSng", "CSng(expression) ", "Converts an expression to a variant of subtype Single\n+" +
				"The expression must be a numeric value.") );
						
			_vscriptWords.setValue( "CStr", 				new AutoCompleteItemVO( VDOMImage.Standard, "CStr", "CStr(expression) ", "Converts an expression to a variant of subtype String\n" + 
				"If <b>expression</b> is::\n" + 
				"<ul>" +
					"<li> Boolean - then the CStr function will return a string containing true or false.</li>"+
					"<li> Date - then the CStr function will return a string that contains a date in the short-date format.</li>" + 
					"<li> Null - then a run-time error will occur.</li>" + 
					'<li> Empty - then the CStr function will return an empty string ("").</li>' + 
					'<li> Error - then the CStr function will return a string that contains the word "Error" followed by an error number.</li>' + 
					"<li> Other numeric - then the CStr function will return a string that contains the number.</li>" +  
				"</ul>\n" ));
				
			_vscriptWords.setValue( "Date", 				new AutoCompleteItemVO( VDOMImage.Standard, "Date", "Date", "Returns the current system date" ) );
			_vscriptWords.setValue( "DateAdd", 				new AutoCompleteItemVO( VDOMImage.Standard, "DateAdd", "DateAdd(interval,number,date)", "Returns a date to which a specified time interval has been added\n" + 
									"<b>interval</b>\n" + 
									"Required. The interval you want to add\n" + 
									"Can take the following values:\n" + 
									"<ul>" +
										"<li> yyyy - Year</li>"+
										"<li> q - Quarter</li>" + 
										"<li> m - Month</li>" + 
										"<li> y - Day of year</li>" + 
										"<li> d - Day</li>" + 
										"<li> w - Weekday</li>" + 
										"<li> ww - Week of year</li>" + 
										"<li> h - Hour</li>" + 
										"<li> n - Minute</li>" + 
										"<li> s - Second </li>" + 
									"</ul>\n" +  
									"<b>number</b>\n\n" + 
									"Required. The number of interval you want to add. Can either be positive, for dates in the future, or negative, for dates in the past\n" + 
									"<b>date</b>\n\n" + 
									"Required. Variant or literal representing the date to which interval is added" ) );
			
					
			_vscriptWords.setValue( "Dictionary", 			new AutoCompleteItemVO( VDOMImage.Standard, "Dictionary", "", "" ) );
			_vscriptWords.setValue( "Dim", 					new AutoCompleteItemVO( VDOMImage.Standard, "Dim", "", "" ) );
			_vscriptWords.setValue( "Do", 					new AutoCompleteItemVO( VDOMImage.Standard, "Do", "", "" ) );
			_vscriptWords.setValue( "Double", 				new AutoCompleteItemVO( VDOMImage.Standard, "Double", "", "" ) );
			_vscriptWords.setValue( "Each", 				new AutoCompleteItemVO( VDOMImage.Standard, "Each", "", "" ) );
			_vscriptWords.setValue( "Else", 				new AutoCompleteItemVO( VDOMImage.Standard, "Else", "", "" ) );
			_vscriptWords.setValue( "ElseIf", 				new AutoCompleteItemVO( VDOMImage.Standard, "ElseIf", "", "" ) );
			_vscriptWords.setValue( "Empty", 				new AutoCompleteItemVO( VDOMImage.Standard, "Empty", "", "" ) );
			_vscriptWords.setValue( "End", 					new AutoCompleteItemVO( VDOMImage.Standard, "End", "", "" ) );
			_vscriptWords.setValue( "Eqv", 					new AutoCompleteItemVO( VDOMImage.Standard, "Eqv", "", "" ) );
			_vscriptWords.setValue( "Erase", 				new AutoCompleteItemVO( VDOMImage.Standard, "Erase", "", "" ) );
			_vscriptWords.setValue( "Error", 				new AutoCompleteItemVO( VDOMImage.Standard, "Error", "", "" ) );
			_vscriptWords.setValue( "Exit", 				new AutoCompleteItemVO( VDOMImage.Standard, "Exit", "", "" ) );
			_vscriptWords.setValue( "Exp", 					new AutoCompleteItemVO( VDOMImage.Standard, "Exp", "Exp(number)", "Returns e raised to a power" ) );
			_vscriptWords.setValue( "False", 				new AutoCompleteItemVO( VDOMImage.Standard, "False", "", "" ) );
			_vscriptWords.setValue( "Finally", 				new AutoCompleteItemVO( VDOMImage.Standard, "Finally", "", "" ) );
			_vscriptWords.setValue( "Fix", 					new AutoCompleteItemVO( VDOMImage.Standard, "Fix", "Fix(number)", "Returns the integer part of a specified number" ) );
			_vscriptWords.setValue( "For", 					new AutoCompleteItemVO( VDOMImage.Standard, "For", "", "" ) );
			_vscriptWords.setValue( "Function", 			new AutoCompleteItemVO( VDOMImage.Standard, "Function", "", "" ) );
			_vscriptWords.setValue( "Generic", 				new AutoCompleteItemVO( VDOMImage.Standard, "Generic", "", "" ) );
			_vscriptWords.setValue( "Get", 					new AutoCompleteItemVO( VDOMImage.Standard, "Get", "", "" ) );
			_vscriptWords.setValue( "Hex", 					new AutoCompleteItemVO( VDOMImage.Standard, "Hex", "Hex(number)", "Returns the hexadecimal value of a specified number" ) );
			_vscriptWords.setValue( "If", 					new AutoCompleteItemVO( VDOMImage.Standard, "If", "", "" ) );
			_vscriptWords.setValue( "In", 					new AutoCompleteItemVO( VDOMImage.Standard, "In", "", "" ) );
			_vscriptWords.setValue( "inherits", 			new AutoCompleteItemVO( VDOMImage.Standard, "inherits", "", "" ) );
			_vscriptWords.setValue( "Int", 					new AutoCompleteItemVO( VDOMImage.Standard, "Int", "Int(number)", "Returns the integer part of a specified number" ) );
			_vscriptWords.setValue( "Integer", 				new AutoCompleteItemVO( VDOMImage.Standard, "Integer", "", "" ) );
			_vscriptWords.setValue( "Imp", 					new AutoCompleteItemVO( VDOMImage.Standard, "Imp", "", "" ) );
			_vscriptWords.setValue( "Is", 					new AutoCompleteItemVO( VDOMImage.Standard, "Is", "", "" ) );
			_vscriptWords.setValue( "IsDate", 				new AutoCompleteItemVO( VDOMImage.Standard, "IsDate", "IsDate(expression)", "Returns a Boolean value that indicates if the evaluated expression can be converted to a date" ) );
			_vscriptWords.setValue( "IsFalse", 				new AutoCompleteItemVO( VDOMImage.Standard, "IsFalse", "", "" ) );
			_vscriptWords.setValue( "IsNot", 				new AutoCompleteItemVO( VDOMImage.Standard, "IsNot", "", "" ) );
			_vscriptWords.setValue( "IsTrue", 				new AutoCompleteItemVO( VDOMImage.Standard, "IsTrue", "", "" ) );
			_vscriptWords.setValue( "Let", 					new AutoCompleteItemVO( VDOMImage.Standard, "Let", "", "" ) );
			_vscriptWords.setValue( "Like", 				new AutoCompleteItemVO( VDOMImage.Standard, "Like", "", "" ) );
			_vscriptWords.setValue( "Log", 					new AutoCompleteItemVO( VDOMImage.Standard, "Log", "Log(number)", "The Log function returns the natural logarithm of a specified number. The natural logarithm is the logarithm to the base e." ) );
			_vscriptWords.setValue( "Loop", 				new AutoCompleteItemVO( VDOMImage.Standard, "Loop", "", "" ) );
			_vscriptWords.setValue( "Match", 				new AutoCompleteItemVO( VDOMImage.Standard, "Match", "", "" ) );
			_vscriptWords.setValue( "Matches", 				new AutoCompleteItemVO( VDOMImage.Standard, "Matches", "", "" ) );
			_vscriptWords.setValue( "Mid", 					new AutoCompleteItemVO( VDOMImage.Standard, "Mid", "", "" ) );
			_vscriptWords.setValue( "Mismatch", 			new AutoCompleteItemVO( VDOMImage.Standard, "Mismatch", "", "" ) );
			_vscriptWords.setValue( "Mod", 					new AutoCompleteItemVO( VDOMImage.Standard, "Mod", "", "" ) );
			_vscriptWords.setValue( "New", 					new AutoCompleteItemVO( VDOMImage.Standard, "New", "", "" ) );
			_vscriptWords.setValue( "Next", 				new AutoCompleteItemVO( VDOMImage.Standard, "Next", "", "" ) );
			_vscriptWords.setValue( "Not", 					new AutoCompleteItemVO( VDOMImage.Standard, "Not", "", "" ) );
			_vscriptWords.setValue( "Nothing", 				new AutoCompleteItemVO( VDOMImage.Standard, "Nothing", "", "" ) );
			_vscriptWords.setValue( "Now", 					new AutoCompleteItemVO( VDOMImage.Standard, "Now", "Now", "Returns the current system date and time" ) );
			_vscriptWords.setValue( "Null", 				new AutoCompleteItemVO( VDOMImage.Standard, "Null", "", "" ) );
			_vscriptWords.setValue( "Oct", 					new AutoCompleteItemVO( VDOMImage.Standard, "Oct", "Oct(number)", "Returns the octal value of a specified number" ) );
			_vscriptWords.setValue( "Or", 					new AutoCompleteItemVO( VDOMImage.Standard, "Or", "", "" ) );
			_vscriptWords.setValue( "OrElse", 				new AutoCompleteItemVO( VDOMImage.Standard, "OrElse", "", "" ) );
			_vscriptWords.setValue( "Preserve", 			new AutoCompleteItemVO( VDOMImage.Standard, "Preserve", "", "" ) );
			_vscriptWords.setValue( "Print", 				new AutoCompleteItemVO( VDOMImage.Standard, "Print", "", "" ) );
			_vscriptWords.setValue( "Proxy", 				new AutoCompleteItemVO( VDOMImage.Standard, "Proxy", "", "" ) );
			_vscriptWords.setValue( "Randomize", 			new AutoCompleteItemVO( VDOMImage.Standard, "Randomize", "", "" ) );
			_vscriptWords.setValue( "ReDim", 				new AutoCompleteItemVO( VDOMImage.Standard, "ReDim", "", "" ) );
			_vscriptWords.setValue( "RegExp", 				new AutoCompleteItemVO( VDOMImage.Standard, "RegExp", "", "" ) );
			_vscriptWords.setValue( "request", 				new AutoCompleteItemVO( VDOMImage.Standard, "request", "", "" ) );
			_vscriptWords.setValue( "Rem", 					new AutoCompleteItemVO( VDOMImage.Standard, "Rem", "", "" ) );
			_vscriptWords.setValue( "replace", 				new AutoCompleteItemVO( VDOMImage.Standard, "replace", "", "" ) );
			_vscriptWords.setValue( "response", 			new AutoCompleteItemVO( VDOMImage.Standard, "response", "", "" ) );
			
			_vscriptWords.setValue( "Rnd", 					new AutoCompleteItemVO( VDOMImage.Standard, "Rnd", "Rnd[(number)]", "Returns a random number less than 1 but greater or equal to 0\n" + 
									"If number is:\n" + 
									"<ul>" +
										"<li> &lt;0 - Rnd returns the same number every time</li>"+
										"<li> &gt;0 - Rnd returns the next random number in the sequence</li>" + 
										"<li> =0 - Rnd returns the most recently generated number</li>" + 
										"<li> Not supplied - Rnd returns the next random number in the sequence</li>" + 
									"</ul>" ) );
			
			_vscriptWords.setValue( "Select", 				new AutoCompleteItemVO( VDOMImage.Standard, "Select", "", "" ) );
			_vscriptWords.setValue( "server", 				new AutoCompleteItemVO( VDOMImage.Standard, "server", "", "" ) );
			_vscriptWords.setValue( "Session", 				new AutoCompleteItemVO( VDOMImage.Standard, "Session", "", "" ) );
			_vscriptWords.setValue( "Set", 					new AutoCompleteItemVO( VDOMImage.Standard, "Set", "", "" ) );
			
			_vscriptWords.setValue( "Sgn", 					new AutoCompleteItemVO( VDOMImage.Standard, "Sgn", "Sgn(number)", "Returns an integer that indicates the sign of a specified number\n" + 
									"If number is:\n" + 
									"<ul>" +
										"<li> &gt;0 - Sgn returns 1</li>" + 
										"<li> =0 - Sgn returns 0</li>" + 
										"<li> &lt;0 - Sgn returns -1</li>"+
									"</ul>" ) );
			
			_vscriptWords.setValue( "Sin", 					new AutoCompleteItemVO( VDOMImage.Standard, "Sin", "Sin(number) ", "Returns the sine of a specified number (angle)" ) );
			_vscriptWords.setValue( "Sqr", 					new AutoCompleteItemVO( VDOMImage.Standard, "Sqr", "Sqr(number) ", "Returns the square root of a specified number" ) );
			_vscriptWords.setValue( "Step", 				new AutoCompleteItemVO( VDOMImage.Standard, "Step", "", "" ) );
			_vscriptWords.setValue( "String", 				new AutoCompleteItemVO( VDOMImage.Standard, "String", "", "" ) );
			_vscriptWords.setValue( "Sub", 					new AutoCompleteItemVO( VDOMImage.Standard, "Sub", "", "" ) );
			_vscriptWords.setValue( "Tan", 					new AutoCompleteItemVO( VDOMImage.Standard, "Tan", "Tan(number)", "Returns the tangent of a specified number (angle)" ) );
			_vscriptWords.setValue( "Then", 				new AutoCompleteItemVO( VDOMImage.Standard, "Then", "", "" ) );
			_vscriptWords.setValue( "this", 				new AutoCompleteItemVO( VDOMImage.Standard, "this", "", "" ) );
			_vscriptWords.setValue( "Time", 				new AutoCompleteItemVO( VDOMImage.Standard, "Time", "Time", "Returns the current system time" ) );
			_vscriptWords.setValue( "Timer", 				new AutoCompleteItemVO( VDOMImage.Standard, "Timer", "Timer", "Returns the number of seconds since 12:00 AM" ) );
			_vscriptWords.setValue( "To", 					new AutoCompleteItemVO( VDOMImage.Standard, "To", "", "" ) );
			_vscriptWords.setValue( "ToJSON", 				new AutoCompleteItemVO( VDOMImage.Standard, "ToJSON", "", "" ) );
			_vscriptWords.setValue( "True", 				new AutoCompleteItemVO( VDOMImage.Standard, "True", "", "" ) );
			_vscriptWords.setValue( "Try", 					new AutoCompleteItemVO( VDOMImage.Standard, "Try", "", "" ) );
			_vscriptWords.setValue( "UBound", 				new AutoCompleteItemVO( VDOMImage.Standard, "UBound", "", "" ) );
			_vscriptWords.setValue( "Until", 				new AutoCompleteItemVO( VDOMImage.Standard, "Until", "", "" ) );
			_vscriptWords.setValue( "Use", 					new AutoCompleteItemVO( VDOMImage.Standard, "Use", "", "" ) );
			_vscriptWords.setValue( "VdomDbConnection", 	new AutoCompleteItemVO( VDOMImage.Standard, "VdomDbConnection", "", "" ) );
			_vscriptWords.setValue( "VDOMDBRecordSet", 		new AutoCompleteItemVO( VDOMImage.Standard, "VDOMDBRecordSet", "", "" ) );
			_vscriptWords.setValue( "VDOMDBRow", 			new AutoCompleteItemVO( VDOMImage.Standard, "VDOMDBRow", "", "" ) );
			_vscriptWords.setValue( "VDOMImaging", 			new AutoCompleteItemVO( VDOMImage.Standard, "VDOMImaging", "", "" ) );
			_vscriptWords.setValue( "Wend", 				new AutoCompleteItemVO( VDOMImage.Standard, "Wend", "", "" ) );
			_vscriptWords.setValue( "While", 				new AutoCompleteItemVO( VDOMImage.Standard, "While", "", "" ) );
			_vscriptWords.setValue( "WHOLEConnection", 		new AutoCompleteItemVO( VDOMImage.Standard, "WHOLEConnection", "", "" ) );
			_vscriptWords.setValue( "WHOLEError", 			new AutoCompleteItemVO( VDOMImage.Standard, "WHOLEError", "", "" ) );
			_vscriptWords.setValue( "WHOLEConnectionError", new AutoCompleteItemVO( VDOMImage.Standard, "WHOLEConnectionError", "", "" ) );
			_vscriptWords.setValue( "WHOLENoConnectionError", 	new AutoCompleteItemVO( VDOMImage.Standard, "WHOLENoConnectionError", "", "" ) );
			_vscriptWords.setValue( "WHOLERemoteCallError", 	new AutoCompleteItemVO( VDOMImage.Standard, "WHOLERemoteCallError", "", "" ) );
			_vscriptWords.setValue( "WHOLEIncorrectResponse", 	new AutoCompleteItemVO( VDOMImage.Standard, "WHOLEIncorrectResponse", "", "" ) );
			_vscriptWords.setValue( "WHOLENoAPIError", 		new AutoCompleteItemVO( VDOMImage.Standard, "WHOLENoAPIError", "", "" ) );
			_vscriptWords.setValue( "WHOLENoApplication", 	new AutoCompleteItemVO( VDOMImage.Standard, "WHOLENoApplication", "", "" ) );
			_vscriptWords.setValue( "With", 				new AutoCompleteItemVO( VDOMImage.Standard, "With", "", "" ) );
			_vscriptWords.setValue( "XMLAttribute", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLAttribute", "", "" ) );
			_vscriptWords.setValue( "XMLDocument", 			new AutoCompleteItemVO( VDOMImage.Standard, "XMLDocument", "", "" ) );
			_vscriptWords.setValue( "XMLDomstirngSizeError",new AutoCompleteItemVO( VDOMImage.Standard, "XMLDomstirngSizeError", "", "" ) );
			_vscriptWords.setValue( "XMLElement", 			new AutoCompleteItemVO( VDOMImage.Standard, "XMLElement", "", "" ) );
			_vscriptWords.setValue( "XMLError", 			new AutoCompleteItemVO( VDOMImage.Standard, "XMLError", "", "" ) );
			_vscriptWords.setValue( "XMLHierarchyRequestError", 	new AutoCompleteItemVO( VDOMImage.Standard, "XMLHierarchyRequestError", "", "" ) );
			_vscriptWords.setValue( "XMLIndexSizeError", 			new AutoCompleteItemVO( VDOMImage.Standard, "XMLIndexSizeError", "", "" ) );
			_vscriptWords.setValue( "XMLInuseAttributeError", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLInuseAttributeError", "", "" ) );
			_vscriptWords.setValue( "XMLInvalidAccessError", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLInvalidAccessError", "", "" ) );
			_vscriptWords.setValue( "XMLInvalidCharacterError", 	new AutoCompleteItemVO( VDOMImage.Standard, "XMLInvalidCharacterError", "", "" ) );
			_vscriptWords.setValue( "XMLInvalidModificationError", 	new AutoCompleteItemVO( VDOMImage.Standard, "XMLInvalidModificationError", "", "" ) );
			_vscriptWords.setValue( "XMLInvalidStateError", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLInvalidStateError", "", "" ) );
			_vscriptWords.setValue( "XMLNamespaceError", 			new AutoCompleteItemVO( VDOMImage.Standard, "XMLNamespaceError", "", "" ) );
			_vscriptWords.setValue( "XMLNoDataAllowedError", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLNoDataAllowedError", "", "" ) );
			_vscriptWords.setValue( "XMLNotFoundError", 			new AutoCompleteItemVO( VDOMImage.Standard, "XMLNotFoundError", "", "" ) );
			_vscriptWords.setValue( "XMLNotSupportedError", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLNotSupportedError", "", "" ) );
			_vscriptWords.setValue( "XMLNode", 						new AutoCompleteItemVO( VDOMImage.Standard, "XMLNode", "", "" ) );
			_vscriptWords.setValue( "XMLSyntaxError", 				new AutoCompleteItemVO( VDOMImage.Standard, "XMLSyntaxError", "", "" ) );
			_vscriptWords.setValue( "XMLWrongDocumentError", 		new AutoCompleteItemVO( VDOMImage.Standard, "XMLWrongDocumentError", "", "" ) );
			_vscriptWords.setValue( "Xor", 							new AutoCompleteItemVO( VDOMImage.Standard, "Xor", "", "" ) );
			
			var f : Field;
			var param : Field;
			
			if ( !_vscriptFields )
			{
				_vscriptFields = new HashList();
				
				//Abs(number)
				setField("abs", new Array("number") );
				
				//Atn(number)
				setField("atn", new Array("number") );
				
				//CBool(expression)
				setField("cbool", new Array("expression") );
				
				//CByte(expression)
				setField("cbyte", new Array("expression") );
				
				//CDate(date)
				setField("cdate", new Array("date") );
				
				//CDbl(expression)
				setField("cdbl", new Array("expression") );
				
				//Chr(charcode)
				setField("chr", new Array("charcode") );
				
				//CInt(expression)
				setField("cint", new Array("expression") );
				
				//CLng(expression)
				setField("clng", new Array("expression") );
				
				//Cos(number)
				setField("cos", new Array("number") );
								
				//CSng(expression)
				setField("csng", new Array("expression") );
				
				//CStr(expression)
				setField("cstr", new Array("expression") );
				
				//DateAdd(number)
				setField("dateadd", new Array("interval", "number", "date") );
				
				//Exp(number)
				setField("exp", new Array("number") );
				
				//Hex(number)
				setField("hex", new Array("number") );
				
				//Int(number)
				setField("int", new Array("number") );
				
				//IsDate(expression)
				setField("IsDate", new Array("expression") );
				
				//Fix(number)
				setField("fix", new Array("number") );
				
				//Log(number)
				setField("log", new Array("number") );
				
				//Oct(number)
				setField("oct", new Array("number") );
				
				//Rnd(number)
				setField("rnd", new Array("number") );
				
				//Sgn(number)
				setField("sgn", new Array("number") );
				
				//Sin(number)
				setField("sin", new Array("number") );
				
				//Sqr(number)
				setField("sqr", new Array("number") );
				
				//Tan(number)
				setField("tan", new Array("number") );
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
				
				_vscriptFields.setValue( name, f );
			}
		}
	}
}