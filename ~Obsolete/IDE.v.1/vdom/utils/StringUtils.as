package vdom.utils
{
public class StringUtils
{
	public static function getLocalName( name : Object) : String
	{
		if (name is QName)
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
}
}