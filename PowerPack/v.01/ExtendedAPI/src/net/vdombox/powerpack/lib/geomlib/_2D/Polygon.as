package src.net.vdombox.powerpack.lib.geomlib._2D
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
public class Polygon extends Object
{	
	public var points:Array = []; 
	
	public function Polygon(...args)
	{
		for(var i:int=0; i<args.length; i++)
		{
			if(args[i] is Point)
				points.push(args[i]);
			else if(args[i] is Array)
				pushPoints(args[i]);
		}
	}
	
	private function pushPoints(arr:Array):void
	{
		for(var i:int=0; i<arr.length; i++)
		{
			if(arr[i] is Point)
				points.push(arr[i]);
			else if(arr[i] is Array)
				pushPoints(arr[i]);
		}		
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
		
    public function get length():Number
    {
    	var len:int = points.length;
    	var polyLen:Number = 0.0;
    	
    	for(var i:int=0; i<len; i++)
    		polyLen += Point.distance(points[i%len], points[(i+1)%len]);
    	
    	return polyLen; 
    }
    
    public function get size():Rectangle
    {
    	var rect:Rectangle;
    	var len:int = points.length;
    	
    	for(var i:int=0; i<len; i++)
    	{
    		if(i==0)
    			rect = new Rectangle(points[i].x, points[i].y);
    		
    		rect.left = Math.min(rect.left, points[i].x);    		
    		rect.top = Math.min(rect.top, points[i].y);    		
    		rect.right = Math.max(rect.right, points[i].x);    		
    		rect.bottom = Math.max(rect.bottom, points[i].y);    		
    	}
    	
    	return rect;
    }

    // TODO: public function get area():Number

 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//-------------------------------------------------------------------------- 
    
    public function clone():Polygon
    {
    	return new Polygon(points);	
    }    	
    
    public function offset(dx:Number, dy:Number):void
    {
    	var len:int = points.length;    	
    	for(var i:int=0; i<len; i++)
    		Point(points[i]).offset(dx, dy);
    }
    
    // TODO: public function inflate(dx:Number, dy:Number):void

    public function transform(matrix:Matrix):Polygon
    {
    	var poly:Polygon = new Polygon();
    	var len:int = points.length;    	
    	for(var i:int=0; i<len; i++)
    		poly.points.push(matrix.transformPoint(points[i]));
    		
    	return poly;
    }
    
    public function equals(toCompare:Polygon):Boolean
    {
    	var len1:int = points.length;    	
    	var len2:int = toCompare.points.length;    	

    	if(len1 != len2)
    		return false;    	
		
		var i:int=0;
		var j:int=0;
    	for(i=0; i<len1; i++) {
    		for(j=0; j<len2; j++) {
				if(!Point(points[(i+j)%len1]).equals(Point(toCompare.points[j])))
					break;
    		}
    		if(j==len2)
    			return true; 
    	}
    	
    	return false;		
    }    

    // TODO: public function containsPoint(point:Point, precision:Number=0.001):Boolean
    
    public function isSelfIntersection():Boolean
    {
    	var len:int = points.length;    	
    	for(var i:int=0; i<len-1; i++) {
	    	for(var j:int=i+1; j<len; j++) {
	    		var seg1:LineSegment = new LineSegment(points[i%len], points[(i+1)%len]);
	    		var seg2:LineSegment = new LineSegment(points[j%len], points[(j+1)%len]);
	    		
	    		if(seg1.intersection(seg2)!=null)
	    			return true;
    		}
    	}
    	
    	return false; 
    }

    public function intersection(toIntersect:Polygon):Array
    {
    	var len1:int = points.length;    	
    	var len2:int = toIntersect.points.length;
    	var arr:Array = [];
    	    	
    	for(var i:int=0; i<len1; i++) {
    		var seg1:LineSegment = new LineSegment(points[i%len1], points[(i+1)%len1]);
	    	for(var j:int=0; j<len2; j++) {
	    		var seg2:LineSegment = new LineSegment(points[j%len2], points[(j+1)%len2]);
	    		
	    		var pt:Point = seg1.intersection(seg2);
	    		
	    		if(pt!=null)
	    			arr.push(pt);
    		}
    	}
    	
    	return arr; 
    } 

    // TODO: public function polygons():Array 
    
}
}