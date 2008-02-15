package PowerPack.com
{
	import mx.utils.StringUtil;
	
	public class Utils
	{
/* 		public static function replaceDuplicates(object:Object):Object
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
		} */
		
		public static function replaceEscapeSequences(string:String, sequence:String, prefix:String = '\\'):String
		{
			var str:String;
			var pos:int = 0;
			
			str = string.concat();
			
			while(pos<str.length-1)
			{
				pos = str.indexOf(sequence, pos);
				
				if(pos<0 || pos>=str.length)
					break;				
				
				var i:int = pos-1;
				while(i>=0 && str.charAt(i)==prefix)
				{	    						
					i--;
				}
				
				if((pos-i)%2==1)
	    		{
	    			var escapeSym:String;
					var lOffset:int = 0;
					var rOffset:int = 0;
	    			
	    			if(sequence==prefix+"r")
		    			escapeSym="\r";
	    			else if(sequence==prefix+"n")
		    			escapeSym="\n";
	    			else if(sequence==prefix+"t")
		    			escapeSym="\t";
		    		else if(sequence==prefix+"-")
		    		{
		    			escapeSym="";
		    			
		    			if( str.charAt(pos-1)==' ' )
		    				lOffset=1;
		    			if( str.charAt(pos+sequence.length)==' ' )
		    				rOffset=1;
		    		}
	    			else
	    				escapeSym=sequence.substring(1);
	    				
	    			str = str.substring(0, pos-lOffset) + escapeSym + str.substring(pos+sequence.length+rOffset);
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