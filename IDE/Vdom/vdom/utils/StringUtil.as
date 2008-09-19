package vdom.utils
{
public class StringUtil
{
	public static function getLocalName(name:Object):String
	{
		if (name is QName)
		{
			return QName(name).localName;
		}
		else
		{
			return String(name);
		}
	}
}
}