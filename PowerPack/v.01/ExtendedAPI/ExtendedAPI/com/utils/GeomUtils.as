package ExtendedAPI.com.utils
{
import flash.geom.Rectangle;

import mx.collections.ListCollectionView;
	
public final class GeomUtils
{
    public static function getPointObjects(...args):Array
    {
		var ret:Array = [];
		
		var tmpArr:Array = [];
		var points:Array = [tmpArr];
		
		for each (var arg:* in args)
		{
			if(!arg)
				continue;
			else if(arg is Array || arg is ListCollectionView )			
				points.push(arg);
			else if(arg.hasOwnProperty('x') && arg.hasOwnProperty('y'))
				tmpArr.push(arg);
		}		
				
		var arr:Object;
		var p:Object;
		
   		for each(arr in points) {
	   		for each(p in arr) {
	   			if(p.hasOwnProperty('x') && p.hasOwnProperty('y'))
	   			{
	   				ret.push(p);
	   			}
   			}
   		}
   		   		
   		return ret;
    }

    public static function getObjectsRect(...args):Rectangle
    {
		var rect:Rectangle = new Rectangle();
		var isEmpty:Boolean = true;
		
		var arr:Array = getPointObjects.apply(null, args);
		
		for each(var p:* in arr) {
   			if(p.hasOwnProperty('x') && p.hasOwnProperty('y'))
   			{
   				if(isEmpty) 
   				{
   					isEmpty = false;
	   				rect.left = rect.right = p.x;
	   				rect.top = rect.bottom = p.y;
   				}
   				
   				rect.left = Math.min(rect.left, p.x);
   				rect.top = Math.min(rect.top, p.y);
   				rect.right = Math.max(rect.right, p.x);
   				rect.bottom = Math.max(rect.bottom, p.y);
	   			
	   			if(p.hasOwnProperty('width') && p.hasOwnProperty('height'))
   				{
   					rect.left = Math.min(rect.left, p.x+p.width);
   					rect.top = Math.min(rect.top, p.y+p.height);
   					rect.right = Math.max(rect.right, p.x+p.width);
   					rect.bottom = Math.max(rect.bottom, p.y+p.height);
   				}
   			}
   		}
   		   		
   		return rect;
    }

    public static function offsetObjects(dX:Number, dY:Number, ...args):void
    {
		var arr:Array = getPointObjects.apply(null, args);
		
		for each(var p:* in arr) {
   			if(p.hasOwnProperty('x') && p.hasOwnProperty('y'))
   			{
   				p.x += dX;
   				p.y += dY;
   			}
   		}
    }

}
}