package PowerPack.com
{
	public class Utils
	{
		public static function ReplaceSingleQuotes(_str:String):String
		{
			var str:String;

			str = _str.replace(/(^'|'$)/g, "");
			str = str.replace(/\\'/g, "'");
			
			return str;
		}
		
		public static function ReplaceDoubleQuotes(_str:String):String
		{
			var str:String;

			str = _str.replace(/(^"|"$)/g, "");
			str = str.replace(/\\"/g, "\"");
			
			return str;
		}
		
		public static function DoubleQuotes(_str:String):String
		{
			var str:String;

			str = _str.replace(/"/g, "\\\"");
			str = "\"" + str + "\""
			
			return str;
		}
		
		public static function Trim(_str:String):String
		{
			var str:String;

			str = _str.replace(/(^\s+|\s+$)/g, "");
			
			return str;
		}
	}
}