package net.vdombox.components.xmldialogeditor.utils
{
	public class StringUtil
	{
		public function StringUtil()
		{
		}
		
		public static function stringIsAValidNumber(s: String) : Boolean 
		{
			return Boolean(s.match(/^[0-9]+.?[0-9]+$/));
		}
		
		public static function stringIsAValidBoolean(s: String) : Boolean 
		{
			s = s.toLowerCase();
			if ( s == "true" || s == "false" )
				return true;
			else
				return false;
		}
	}
}