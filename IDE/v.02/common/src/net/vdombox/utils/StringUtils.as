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
		
		public static function getCDataParserString( str : Object ) : String
		{
			return str.replace(/]]>/g, "]]]]><![CDATA[>");
		}
		
		public static function htmlEnc( str : String ) : String
		{
			return str.replace( /&/g, "&amp;" ).replace( /\</g, "&lt;" ).replace( /\>/g, "&gt;" );
		}
	}
}