package ExtendedAPI.com.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.describeType;
	
	import mx.core.Container;
	import mx.utils.StringUtil;
	
	public class Utils
	{
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
				
		/*
		public static function replaceQuotes(_str:String):String
		{
			var str:String;

			if(_str.charAt(0) == '"')
			{
				str = _str.replace(/(^"|"$)/g, "");
				str = replaceEscapeSequences(str, '\\"');
			}
			else if(_str.charAt(0) == "'")
			{
				str = _str.replace(/(^'|'$)/g, "");
				str = replaceEscapeSequences(str, "\\'");
			}
			else
			{
				str = _str.concat();
			}
			
			return str;
		}
		*/
		
		public static function replaceQuotes(_str:String):String
		{
			var str:String;
			var char:String;
			var buf:String;
						
			if(_str.charAt(0) == '"')
			{
				str = _str.replace(/(^"|"$)/g, "");
				char = '"';
			}
			else if(_str.charAt(0) == "'")
			{
				str = _str.replace(/(^'|'$)/g, "");
				char = "'";
			}
			else
			{
				buf = _str.concat();
			}			
			
			if(char)
			{
				buf = "";
			
				for(var i:int=0; i<str.length; i++)
				{
					if(str.charAt(i)=='\\')
					{
						if(str.charAt(i+1)=='\\' || str.charAt(i+1)==char)
							i++;
					}
					
					buf += str.charAt(i);					
				}
			}
			
			return buf;
		}
		
		public static function quotes(_str:String, isSingle:Boolean=false):String
		{
			var str:String;
			var qoute:String = isSingle ? "'" : '"';
			
			str = "";
			
			for(var i:int=0; i<_str.length; i++)
			{
				if(_str.charAt(i)==qoute)
				{
					/*
					var j:int = i-1;
					while(j>=0 && _str.charAt(j)=="\\") {	    						
						j--;
					}
	
					if((i-j)%2==1) {
						str += "\\";
					}
					*/
					
					str += '\\';					
				}
				else if(_str.charAt(i)=='\\')
				{
					str += '\\';
				}
				
				str += _str.charAt(i);					
			}
			
			str = qoute + str + qoute;
			
			return str;
		}

		public static function getNumberOrDefault(object:Object, default_val:Number = 0):Number
		{
			return (object && StringUtil.trim(object.toString()) && !isNaN(Number(object)) ? Number(object) : default_val);
		}
				
		public static function getStringOrDefault(object:Object, default_val:String=null):String
		{
			return (object && StringUtil.trim(object.toString()) ? object.toString() : default_val);
		}
		
		public static function getBooleanOrDefault(str_object:Object, default_val:Boolean=false):Boolean
		{			
			var str:String = str_object ? StringUtil.trim(str_object.toString()).toLowerCase() : null;
			
			return (str=='true' ? true : str=='false' ? false : default_val);
		}
		
		public static function getExactRect(obj:DisplayObject):Rectangle
		{
			if(!obj.parent || !(obj.parent is Container))
				return null;
				
			var rect:Rectangle = new Rectangle();
			rect.topLeft = (obj.parent as Container).contentToGlobal(new Point(obj.x, obj.y));
			rect.width = obj.width;		
			rect.height = obj.height;
				
			return rect;			
		}
	
		public static function getVisibleExactRect(obj:DisplayObject):Rectangle
		{
			if(!obj.parent || !(obj.parent is Container))
				return null;
			
			var rect1:Rectangle = getExactRect(obj);
			rect1.x += (obj.parent as Container).horizontalScrollPosition;
			rect1.y += (obj.parent as Container).verticalScrollPosition;
			rect1.width -= (obj.parent as Container).maxHorizontalScrollPosition;		
			rect1.height -= (obj.parent as Container).maxVerticalScrollPosition;
			
			var rect2:Rectangle = getVisibleExactRect(obj.parent);
			
			var rect:Rectangle = rect1;
			
			if(rect2)
				rect = rect1.intersection(rect2);
			
			return rect;			
		}
		
		public static function keyCodeFromName(keyname:String):uint
		{
			var list:XMLList; 
			var name_const:String;
			var code_const:String;
			var keycode:uint;
			
   			code_const = keyname.toUpperCase();
   			if(Keyboard[code_const] && Keyboard[code_const] is uint) {
   				keycode = Keyboard[code_const];
   				return keycode;
   			}

			list = describeType(Keyboard)..constant.(@type=='String' && @name.toString().substr(0,"KEYNAME_".length)=='KEYNAME_');
			for each(var item:XML in list) {
            	if(Keyboard[item.@name.toString()] && Keyboard[item.@name.toString()] == keyname) {
            		name_const = item.@name.toString();
            		break;
            	}
   			}
   			
   			if(name_const)
   			{
   				code_const = name_const.substr(0,"KEYNAME_".length);
   				if(Keyboard[code_const] && Keyboard[code_const] is uint) {
   					keycode = Keyboard[code_const];
   					return keycode;
   				}
   			}
			
			list = describeType(Keyboard)..constant.(@type=='uint');
			for each(item in list) {	
				code_const = item.@name.toString();			
				var str:String = code_const.replace("_","")
            	if(name_const==str || keyname==str)
            	{
            		keycode = Keyboard[code_const];
   					return keycode;
            	}
   			}

			return keycode;		
		}

	}
}