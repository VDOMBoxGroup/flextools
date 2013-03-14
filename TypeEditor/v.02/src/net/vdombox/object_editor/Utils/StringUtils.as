package net.vdombox.object_editor.Utils
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
		
		public static function toHtmlEnc( str : String ) : String
		{
			return str.replace( /&/g, "&amp;" ).replace( /\</g, "&lt;" ).replace( /\>/g, "&gt;" );
		}
		
		public static function fromHtmlEnc( str : String ) : String
		{
			var str2 : String = str.replace( /&lt;/g, "<" ).replace( /&gt;/g, ">" ).replace( /&apos;/g, '"' ).replace( /&quot;/g, '"' ).replace( /&amp;/g, "&" );
			return str2;
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