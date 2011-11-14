package
{
	public class HtmlPageProperties
	{
		private static var metaTeg		: String = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />";
		private static var cssTeg		: String = "<link rel='stylesheet' href='app-storage:/main.css' type='text/css'></link>";
		private static var scriptTeg	: String = "<script src='app-storage:/searchhi_slim.js'></script>";
		
		// syntaxhighlighter ...
		private static var jsBrushPythonTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushPython.js\"></script>";
		private static var jsBrushAS3Teg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushAS3.js\"></script>";
		private static var jsBrushCppTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushCpp.js\"></script>";
		private static var jsBrushCSharpTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushCSharp.js\"></script>";
		private static var jsBrushCssTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushCss.js\"></script>";
		private static var jsBrushDelphiTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushDelphi.js\"></script>";
		private static var jsBrushJavaTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushJava.js\"></script>";
		private static var jsBrushJScriptTeg	: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushJScript.js\"></script>";
		private static var jsBrushPerlTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushPerl.js\"></script>";
		private static var jsBrushPhpTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushPhp.js\"></script>";
		private static var jsBrushSqlTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushSql.js\"></script>";
		private static var jsBrushVbTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushVb.js\"></script>";
		private static var jsBrushXMLTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushXml.js\"></script>";
		
		private static var jsCoreTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shCore.js\"></script>";
		private static var jsLegacyTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shLegacy.js\"></script>";
		private static var jsXRegExpTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/XRegExp.js\"></script>";
		
		private static var jsCoreCssTeg			: String = "<link type=\"text/css\" rel=\"stylesheet\" href=\"app-storage:/assets/syntax_highlighter/css/shCore.css\"></link>";
		private static var jsThemeDefaultCssTeg	: String = "<link type=\"text/css\" rel=\"stylesheet\" href=\"app-storage:/assets/syntax_highlighter/css/shThemeDefault.css\"></link>";
		// ... syntaxhighlighter
		
		public static var headTemplate : String = 
			"<head>" + "\n" +
				metaTeg + "\n" +
				cssTeg + "\n" +
				scriptTeg + "\n" +
				
				jsXRegExpTeg + "\n" +
				jsCoreTeg + "\n" +
				jsLegacyTeg + "\n" +
				
				jsBrushPythonTeg + "\n" +
				jsBrushAS3Teg + "\n" +
				jsBrushCppTeg + "\n" +
				jsBrushCSharpTeg + "\n" +
				jsBrushCssTeg + "\n" +
				jsBrushDelphiTeg + "\n" +
				jsBrushJavaTeg + "\n" +
				jsBrushJScriptTeg + "\n" +
				jsBrushPerlTeg + "\n" +
				jsBrushPhpTeg + "\n" +
				jsBrushSqlTeg + "\n" +
				jsBrushVbTeg + "\n" +
				jsBrushXMLTeg + "\n" +
				
				jsCoreCssTeg + "\n" +
				jsThemeDefaultCssTeg + "\n" +
				
			"</head>" + "\n";
		
		public static var highlightAllTemplate : String = "<script type=\"text/javascript\">dp.SyntaxHighlighter.HighlightAll('code', true, false, false);</script>";
		
		public function HtmlPageProperties()
		{
		}
		
	}
	
}
