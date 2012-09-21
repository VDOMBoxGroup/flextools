package net.vdombox.editors.parsers
{
	import net.vdombox.editors.parsers.python.PythonTokenizer;
	import net.vdombox.editors.parsers.vdomxml.VdomXMLTokenizer;
	import net.vdombox.editors.parsers.vscript.VScriptTokenizer;

	public class FactoryTokenizers
	{
		public function FactoryTokenizers()
		{
		}
		
		public static function getTokenizer( lang : String, string : String ) : Tokenizer
		{
			switch(lang)
			{
				case LanguageVO.python:
				{
					return new PythonTokenizer( string );
				}
					
				case LanguageVO.vscript:
				{
					return new VScriptTokenizer( string );
				}
					
				default:
				{
					return new VdomXMLTokenizer( string )
				}
			}
		}
	}
}