package net.vdombox.utils
{

	public class StringUtils
	{
		public static function getLocalName( name : Object ) : String
		{
			if ( name is QName )
			{
				return QName( name ).localName;
			}
			else
			{
				return String( name );
			}
		}

		public static function isDigit( ch : String ) : Boolean
		{
			return ch >= '0' && ch <= '9';
		}
		
		public static function getCDataParserString( str : String ) : String
		{
			return str.replace(/]]>/g, "]]]]><![CDATA[>");
		}
		
		public static function htmlEnc( str : String ) : String
		{
			return str.replace( /&/g, "&amp;" ).replace( /\</g, "&lt;" ).replace( /\>/g, "&gt;" );
		}
		
		public static  function getNumberLine( script : String, index : int ) : int
		{
			var count : int = 0;
			var i : int = -1;
			do
			{
				i = script.indexOf( "\n", i + 1 );
				count++;
			}
			while( i < index && i >= 0 );
			
			return count;
		}
	}
}