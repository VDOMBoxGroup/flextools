package PowerPack.com
{
	import mx.utils.StringUtil;
	
	public class Utils
	{
		public static function replaceDuplicates(object:Object):Object
		{
			var obj:Object;
			
			if(obj is String)
			{
				obj = String(object).concat();				
			}
			else
			{
				obj = object;
			}
			
			return obj;
		}
				
		public static function replaceEscapeCharacters(string:String, sequences:String, prefix:String = '\\'):String
		{
			var str:String;
			var pattern:RegExp;
			
			str = string.concat();
			sequences += prefix;
			
			for (var i:int=0; i<sequences.length; i++)
			{
				pattern = new RegExp(prefix+sequences.charAt(i), "g");
				
				str = str.replace(pattern, prefix+prefix+sequences.charAt(i));				
			}
			
			return str;
		}
		
		public static function replaceEscapeSequences(string:String, sequences:String, prefix:String = '\\'):String
		{
			var str:String;
			var pos:int = 0;
			var pattern:RegExp;
			
			str = string.concat();
			
			while(pos<str.length-1)
			{
				pos = str.indexOf(prefix, pos);
				
				if(pos<0 || pos>=str.length)
					break;				
				
				for (var i:int=0; i<sequences.length; i++)
				{
					if(sequences.charAt(i)==str.charAt(pos+1))
					{
						//str = str.substring(0, pos) + str.substring(pos+1	
						break;
					}
				}
				
				pos ++;	
			}			
			return str;
		}
				
		public static function replaceSingleQuotes(_str:String):String
		{
			var str:String;
			
			if(_str.charAt(0) != "'")
				return _str;

			str = _str.replace(/(^'|'$)/g, "");
			str = str.replace(/\\'/g, "'");
			
			return str;
		}
		
		public static function replaceDoubleQuotes(_str:String):String
		{
			var str:String;

			if(_str.charAt(0) != '"')
				return _str;

			str = _str.replace(/(^"|"$)/g, "");
			str = str.replace(/\\"/g, "\"");
			
			return str;
		}
		
		public static function doubleQuotes(_str:String):String
		{
			var str:String;

			str = _str.replace(/"/g, "\\\"");
			str = "\"" + str + "\""
			
			return str;
		}
		
	}
}