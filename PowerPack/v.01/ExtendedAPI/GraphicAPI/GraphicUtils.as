package GraphicAPI
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.Point;

public class GraphicUtils
{
	
	public static function objToBitmapData(object:Object):BitmapData
	{
		var bd:BitmapData;
		
		if(object is DisplayObject)
		{
			var displayObj:DisplayObject = DisplayObject(object);
			bd = new BitmapData(displayObj.width, displayObj.height, true, 0x00000000);
			bd.draw(displayObj);
		}
		
		return bd;
	}
	
	/**
	 * 
	 * Converts array of objects into array of points.
	 * 
	 * @param points
	 * @return Array of points.
	 * 
	 */
	public static function processPointArray(points:Array):Array
	{
		var arr:Array = []; 
		var i:int;
		var needSecond:Boolean = false;
		
		for(i=0; i<points.length; i++)
		{				
			if(points[i].hasOwnProperty('x') && points[i].hasOwnProperty('y'))
			{
				if(isNaN(points[i].x) || isNaN(points[i].y) || needSecond)
					return [];
					
				arr.push(new Point(Number(points[i].x), Number(points[i].y)));
			}
			else if(points[i].hasOwnProperty('X') && points[i].hasOwnProperty('Y'))
			{
				if(isNaN(points[i].X) || isNaN(points[i].Y) || needSecond)
					return [];
					
				arr.push(new Point(Number(points[i].X), Number(points[i].Y)));
			}
			else if(points[i] is Array && points[i].length==2)
			{
				if(isNaN(points[i][0]) || isNaN(points[i][1]) || needSecond)
					return [];
				
				arr.push(new Point(Number(points[i][0]), Number(points[i][1])));
			}
			else
			{
				if(isNaN(points[i]))
					return [];

				if(needSecond)
				{
					needSecond = false;
					arr.push(new Point(Number(points[i-1]), Number(points[i])));
				}
				else
					needSecond = true;
			}				
		}
		
		if(needSecond)
			return [];
			
		return arr;
	}
    
	/**
	 * Convert color from RGB to HSV format.
	 * 
	 * @param rgb Color in RGB format.
	 * @return {h, s, v}, where h=[0..360], s=[0..1], v=[0..1].
	 * 
	 */
	public static function RGB2HSV(rgb:uint):Object
	{
		// h=[0..360] s=[0..1] v=[0..1]
		var hsv:Object = {h:0.0, s:0.0, v:0.0};		
		
		var r:Number = ((rgb&0xff0000)>>16) / 255;
		var g:Number = ((rgb&0x00ff00)>>8) / 255;
		var b:Number = (rgb&0x0000ff) / 255;

		var maxc:Number = Math.max(r,g,b);
		var minc:Number = Math.min(r,g,b);
		var dmax:Number = maxc-minc;
		
		hsv.v = maxc;
		
		if(maxc != 0.0) 
			hsv.s = dmax/maxc;
		
		if(hsv.s == 0.0) 
			hsv.h = 0.0;
		else
		{
			var rc:Number = (maxc-r)/dmax;
			var gc:Number = (maxc-g)/dmax;
			var bc:Number = (maxc-b)/dmax;
			
			if(r == maxc) 
				hsv.h = bc-gc
			else if(g == maxc) 
				hsv.h = 2+rc-bc
			else  
				hsv.h = 4+gc-rc;
			
			hsv.h *= 60;
			
			while(hsv.h < 0.0) 
				hsv.h += 360.0;
				
			hsv.h %= 360.0;
		}
		return hsv;	
	}
	
	/**
	 * Convert color from HSV to RGB format.
	 * 
	 * @param h [0..360]
	 * @param s [0..1]
	 * @param v [0..1]
	 * @return Color in RGB format.
	 * 
	 */	
	public static function HSV2RGB(h:Number, s:Number, v:Number):uint
	{
		var r:int;
		var g:int;
		var b:int;
		
  		if(s == 0.0)
  		{
     		r = Math.round(v*255);
     		g = Math.round(v*255);
     		b = Math.round(v*255);
  		}
  		else
  		{
      		var i:Number;
      		h %= 360.0;
      		
      		if(h < 0) 
      			h = -h;
      			
      		h /= 60;
      		i = Math.floor(h);
      		var fr:Number = h - i;
      		
      		var c1:Number = v*(1.0 - s);
      		var c2:Number = v*(1.0 - s*fr);
      		var c3:Number = v*(1.0 - s*(1.0 - fr));
      		
      		switch(i)
      		{
         		case 0: 
         			r=Math.round(v*255);  g=Math.round(c3*255); b=Math.round(c1*255); break;         			
		        case 1: 
		        	r=Math.round(c2*255); g=Math.round(v*255); b=Math.round(c1*255); break;
		        case 2: 
		        	r=Math.round(c1*255); g=Math.round(v*255); b=Math.round(c3*255); break;
		        case 3: 
		        	r=Math.round(c1*255); g=Math.round(c2*255); b=Math.round(v*255); break;
		        case 4: 
		        	r=Math.round(c3*255); g=Math.round(c1*255); b=Math.round(v*255); break;
		        case 5: 
		        	r=Math.round(v*255); g=Math.round(c1*255); b=Math.round(c2*255); break;
      		}
  		}
  		
  		return ((r&0xff)<<16) + ((g&0xff)<<8) + (b&0xff); 
	}
}
}