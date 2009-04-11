package ExtendedAPI.com.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.describeType;
	
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.utils.StringUtil;
	
	public class Utils
	{
 		public static function bringToFront(obj:DisplayObject):void
		{
	        // Make sure a parent container exists.
	        if(obj.parent)
	        {
	        	try {
	        		// if object is child
	           		if (obj.parent.getChildIndex(obj) < obj.parent.numChildren-1)
		   		   		obj.parent.setChildIndex(obj, obj.parent.numChildren-1);
	           	} catch(e:*) {
	           		// if object is raw child
		        	Container(obj.parent).rawChildren.setChildIndex(obj,
		        		Container(obj.parent).rawChildren.numChildren-1) 
	           	}
	        }		 
		}
		
		public static function scrollToObject(obj:UIComponent):void
		{
			if(!obj.parent)
				return;
				
			if(!(obj.parent is Container))
				return;
			
			var cP:Point = new Point(	obj.x + obj.getExplicitOrMeasuredWidth()/2, 
										obj.y + obj.getExplicitOrMeasuredHeight()/2);  
			
			Container(obj.parent).verticalScrollPosition = cP.y - Container(obj.parent).height/2;
			Container(obj.parent).horizontalScrollPosition = cP.x - Container(obj.parent).width/2
		}
		
		public static function scrollToContentPoint(content:Container, p:Point):void
		{
			content.verticalScrollPosition = p.y - content.height/2;
			content.horizontalScrollPosition = p.x - content.width/2
		}		
	
	 	public static function isEqualArrays(arr1:Array, arr2:Array, strict:Boolean = false):Boolean
	 	{
	 		if(!arr1 && !arr2)
	 			return true;  
	 		
	 		if(!arr1 || !arr2)
	 			return false;  
	 			 		
	 		if(arr1.length != arr2.length)
	 			return false;
	 		
	 		if(strict)
	 		{
	 			for(var i:int=0; i<arr1.length; i++)
	 			{
	 				if(arr1[i]!=arr2[i])
	 					return false;	
	 			}
	 		}
	 		else
	 		{
	 			for each(var elm1:Object in arr1)
	 			{
	 				var notExist:Boolean = true;
		 			for each(var elm2:Object in arr2)
		 			{
		 				if(elm1==elm2)
		 				{
		 					notExist = false;
		 					break;
		 				}		
		 			}
		 			if(notExist)
		 				return false; 				
	 			}
	 		}
	 		return true; 
	 	}
	 	
		public static function replaceEscapeSequences(string:String, sequence:String, prefix:String = '\\'):String
		{
			var str:String = string.concat();
			var len:int = str.length;
			var index:int;
			
			while(index<len-1)
			{
				index = str.indexOf(sequence, index);
				
				if(index<0 || index>=len)
					break;				
				
				var count:int = index-1;
				while(count>=0 && str.charAt(count)==prefix)
					count--;
				
				if((index-count)%2==1)
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
		    			
		    			if( str.charAt(index-1)==' ' )
		    				lOffset=1;
		    			if( str.charAt(index+sequence.length)==' ' )
		    				rOffset=1;
		    		}
	    			else
	    				escapeSym=sequence.substring(1);
	    				
	    			str = str.substring(0, index-lOffset) + escapeSym + str.substring(index+sequence.length+rOffset);
	    			len = str.length;
	    		}	
	    				
				index ++;	
			}			
			return str;
		}

		public static function replaceBracers(string:String, bracers:String='({['):String
		{
			var str:String = string.concat();
			var bracer:String = str.charAt(0);
			var closeBracer:String;
			
			if("({[".indexOf(bracer)>=0 && bracers.indexOf(bracer)>=0)
				closeBracer = ")}]".charAt("({[".indexOf(bracer));
			
			if(closeBracer && str.charAt(str.length-1)==closeBracer)
			{
				str = str.substr(1, str.length-2);
			}
			
			return str;
		}
		
		public static function replaceAllBracers(string:String, bracers:String='({['):String
		{
			var str:String = string.concat();
			var len:int;
			
			do
			{
				len = str.length;
				str = replaceBracers(str, bracers);				
			} while(len!=str.length)
			
			return str;
		}		
					
		public static function replaceQuotes(string:String):String
		{
			var str:String;
			var buf:String;
			var quote:String = string.charAt(0);
						
			if(quote == '"')
				str = string.replace(/(^"|"$)/g, "");
			else if(quote == "'")
				str = string.replace(/(^'|'$)/g, "");
			else {
				buf = string.concat();
				quote = null;				
			}
			
			if(quote)			
			{
				buf = "";
				var len:int = str.length;
				var char:String; 
				
				for(var i:int=0; i<len; i++)
				{
					char = str.charAt(i);
					if(char=='\\')
					{
						var nextChar:String = str.charAt(i+1); 
						if(	nextChar=='\\' || 
							nextChar=='"' ||
							nextChar=="'")
							i++;
					}
					
					buf += char;					
				}
			}
			
			return buf;
		}
		
		public static function quotes(string:String, isSingle:Boolean=false):String
		{
			var str:String;
			var quote:String = isSingle ? "'" : '"';
			var len:int = string.length;
			var char:String;
			
			str = "";
			
			for(var i:int=0; i<len; i++)
			{
				char = string.charAt(i);
				switch (char)
				{
					case "'":
					case '"':
					case '\\':
						str += '\\';					
						break;
				}
				str += char;					
			}
			
			str = quote + str + quote;
			
			return str;
		}

		public static function getNumberOrDefault(object:Object, defaultValue:Number = 0):Number
		{
			return (object && StringUtil.trim(object.toString()) && !isNaN(Number(object)) ? Number(object) : defaultValue);
		}
				
		public static function getStringOrDefault(object:Object, defaultValue:String=null):String
		{
			return (object && StringUtil.trim(object.toString()) ? object.toString() : defaultValue);
		}
		
		public static function getBooleanOrDefault(str_object:Object, defaultValue:Boolean=false):Boolean
		{			
			var str:String = str_object ? StringUtil.trim(str_object.toString()).toLowerCase() : null;
			
			return (str=='true' ? true : str=='false' ? false : defaultValue);
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
	
		public static function getContentArea(obj:Container):Rectangle
		{
			if(!(obj is Container))
				return null;
				
			var edges:EdgeMetrics = obj.viewMetricsAndPadding;
			var rect:Rectangle = obj.getBounds(obj.stage);
			
			rect.top += edges.top;
			rect.left += edges.left;
			rect.bottom -= edges.bottom;
			rect.right -= edges.right;
			
			return  rect;	
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
		
		public static function getVisibleRect(obj:DisplayObject):Rectangle
		{
			if(!obj.parent || !(obj.parent is Container))
				return null;	
				
			var contentArea:Rectangle = getContentArea(obj.parent as Container);
			var bounds:Rectangle = obj.getBounds(obj.stage);
			
			return bounds.intersection(contentArea);
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