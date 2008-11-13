package ExtendedAPI.com.utils
{
import flash.display.DisplayObject;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;


public class ObjectUtils
{
	public static function dictLength(dict:Dictionary):int
	{
		var count:int = 0;
		for(var d:* in dict)
			count ++;
		return count;	
	} 
	
	/**
	 * Deep clone object using thiswind@gmail.com 's solution
	 */
	public static function baseClone(source:*):*{
		var typeName:String = getQualifiedClassName(source);
        var packageName:String = typeName.split("::")[1];
        var type:Class = Class(getDefinitionByName(typeName));

        registerClassAlias(packageName?packageName:'global', type);
        
        var copier:ByteArray = new ByteArray();
        copier.writeObject(source);
        copier.position = 0;
        return (copier.readObject());
	}

	public static function baseDispose(obj:*):void
	{
		// remove display object from its parent
		if(obj is DisplayObject && DisplayObject(obj).parent)
			DisplayObject(obj).parent.removeChild(obj);
			
		/* TODO: need remove event listeners!!! */
		
		var props:Object = new Object();
		
		// map dynamic properties
		for (var prop:String in obj) {
			props[prop] = true;
		}		
		
		var classDescXML:XML = describeType(obj);
		
		// map properties accessible for write
		var listXML:XMLList = classDescXML..accessor.(@access=='writeonly' || @access=='readwrite');			
        for each(var item:XML in listXML) {
        	props[item.@name] = true;
        }
        
        // map variables
		listXML = classDescXML..variable;			
        for each(item in listXML) {
        	props[item.@name] = true;
        }
		
		// dispose all prperties and variables
		for (prop in props) {
			try {
				obj[prop] = null;
				delete obj[prop]
			} catch(e:*) {}
		}			
	}	
	
	/**
	 * Checks wherever passed-in value is <code>String</code>.
	 */
	public static function isString(value:*):Boolean {
		return ( typeof(value) == "string" || value is String );
	}
	
	/**
	 * Checks wherever passed-in value is <code>Number</code>.
	 */
	public static function isNumber(value:*):Boolean {
		return ( typeof(value) == "number" || value is Number );
	}

	/**
	 * Checks wherever passed-in value is <code>Boolean</code>.
	 */
	public static function isBoolean(value:*):Boolean {
		return ( typeof(value) == "boolean" || value is Boolean );
	}

	/**
	 * Checks wherever passed-in value is <code>Function</code>.
	 */
	public static function isFunction(value:*):Boolean {
		return ( typeof(value) == "function" || value is Function );
	}

	
}
}