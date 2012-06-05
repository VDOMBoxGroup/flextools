package net.vdombox.helpeditor.model
{
	public class HtmlPageProperties
	{
		private static const metaTeg		: String = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />";
		private static const cssTeg		: String = "<link rel='stylesheet' href='app-storage:/main.css' type='text/css'></link>";
		private static const scriptTeg	: String = "<script src='app-storage:/searchhi_slim.js'></script>";
		
		// syntaxhighlighter ...
		private static const jsBrushPythonTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushPython.js\"></script>";
		private static const jsBrushAS3Teg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushAS3.js\"></script>";
		private static const jsBrushCppTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushCpp.js\"></script>";
		private static const jsBrushCSharpTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushCSharp.js\"></script>";
		private static const jsBrushCssTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushCss.js\"></script>";
		private static const jsBrushDelphiTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushDelphi.js\"></script>";
		private static const jsBrushJavaTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushJava.js\"></script>";
		private static const jsBrushJScriptTeg		: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushJScript.js\"></script>";
		private static const jsBrushPerlTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushPerl.js\"></script>";
		private static const jsBrushPhpTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushPhp.js\"></script>";
		private static const jsBrushSqlTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushSql.js\"></script>";
		private static const jsBrushVbTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushVb.js\"></script>";
		private static const jsBrushXMLTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shBrushXml.js\"></script>";
		
		private static const jsCoreTeg				: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shCore.js\"></script>";
		private static const jsLegacyTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/shLegacy.js\"></script>";
		private static const jsXRegExpTeg			: String = "<script type=\"text/javascript\" src=\"app-storage:/assets/syntax_highlighter/js/XRegExp.js\"></script>";
		
		private static const jsCoreCssTeg			: String = "<link type=\"text/css\" rel=\"stylesheet\" href=\"app-storage:/assets/syntax_highlighter/css/shCore.css\"></link>";
		private static const jsThemeDefaultCssTeg	: String = "<link type=\"text/css\" rel=\"stylesheet\" href=\"app-storage:/assets/syntax_highlighter/css/shThemeDefault.css\"></link>";
		
		public static const jsCoreFileName			: String = "/js/shCore.js";
		
		public static const headTemplate : String = 
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
		
		public static const highlightAllTemplate : String = "<script type=\"text/javascript\">dp.SyntaxHighlighter.HighlightAll('code', true, false, false);</script>";
		// ... syntaxhighlighter
		
		//public static const hrefScript			: String = "<script type='text/javascript'>jQuery(function($){ $('a').click(function(){  dohref($(this).attr('href'));  return false; });};);</script>";
		public static const hrefScript			: String = "<script type='text/javascript'>$('a').click(function () {    dohref($(this).attr('href'));    });</script>";
		
		public static const importJQueryScript	: String = "<script type='text/javascript' src='app-storage:/assets/jquery-1.7.2.min.js'></script>";
		
		public function HtmlPageProperties()
		{
		}
		
	}
	
}
