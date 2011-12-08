package net.vdombox.powerpack.lib.geomlib
{
import net.vdombox.powerpack.lib.geomlib._2D.Ellipse;
import net.vdombox.powerpack.lib.geomlib._2D.LineSegment;
import net.vdombox.powerpack.lib.geomlib._2D.Polygon;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.ListCollectionView;

public class GeomUtils
{
    /**
     * Returns angle, in radians, between the line segment from (0,0) to the point and X-axis.
     * 
     * @param point
     * @return Angle (in radians).
     * 
     */
    public static function angle(point:Point):Number
    {
        return Math.atan2(point.y, point.x);     
           	
    }
        
    /**
     * Method determines cross points of the line segment and the ellipse.
     */
    public static function ellipseLineIntersection(e:Ellipse, ls:LineSegment, isBelongToSegment:Boolean=false):Array
    {
    	var arr:Array = [];    	
    	var prec:Number = 0.0000000001;
    	var matrix:Matrix = new Matrix();
    	
		matrix.translate(-e.center.x, -e.center.y);
		matrix.rotate(-e.angle); 	    	
    	
    	var _e:Ellipse = e.transform(matrix);
    	var _ls:LineSegment = ls.transform(matrix);
    	
    	var le:Object = _ls.equationCoefs;   	
    	
    	var aa:Number = Math.pow(le.a, 2);    	
    	var bb:Number = Math.pow(le.b, 2);    	
    	var cc:Number = Math.pow(le.c, 2);    	

    	var AA:Number = Math.pow(_e.A, 2);    	
    	var BB:Number = Math.pow(_e.B, 2);    	
    	
    	var a:Number = aa + bb*(BB/AA);
    	var b:Number = 2*le.a*le.c;
    	var c:Number = cc - bb*BB;
    	var p:Number = b/a;
    	var q:Number = c/a;
    	
    	var D:Number = Math.pow(p, 2) - 4*q;
    	
    	function getY(x:Number):Number {
    		if(le.b!=0)
    			return (-le.a*x - le.c)/le.b;    			
    		return Math.sqrt(BB - x*x*BB/AA); 
    	}

    	function pushPt(pt:Point):void {
    		if(isBelongToSegment) {    		
    		 	if(_ls.containsPoint(pt))
    				arr.push(pt);
    		}
    		else
    			arr.push(pt);    		
    	}
    	
    	D = Math.round(D/prec)*prec;
    	
    	if(D==0) {
    		var x:Number = -p/2;
    		var y:Number = getY(x);
    		
    		pushPt(new Point(x,y));
    		
    		if(le.a==0 || le.b==0) 
    			pushPt(new Point(x,-y));
    	}
    	else if(D>0) {
    		var sqrt:Number = Math.sqrt(D);

    		var x1:Number = (-p + sqrt)/2;
    		var x2:Number = (-p - sqrt)/2;
    		
    		var y1:Number = getY(x1);
    		var y2:Number = getY(x2);
    		
    		pushPt(new Point(x1,y1));    		
    		pushPt(new Point(x2,y2));    		
    	}    	
    	
    	matrix.invert();
    	
    	for(var i:int=0; i<arr.length; i++)
    		arr[i] = matrix.transformPoint(arr[i]);
    		 
    	return arr;
    }
    
    public static function polygonLineIntersection(poly:Polygon, ls:LineSegment, isBelongToSegment:Boolean=false):Array
    {
    	var arr:Array = [];
    	var len:int = poly.points.length;
    	
    	function pushPt(pt:Point):void {
			arr.push(pt);    		
    	}
    	    	
    	if(len==1)
    	{
    		pushPt(poly.points[0]);
    	}
    	else if(len>1)
    	{
    		for(var i:int=0; i<(len==2?len-1:len); i++)
    		{    			
    			var seg:LineSegment = new LineSegment(poly.points[i%len], poly.points[(i+1)%len]);
    			var p:Point = ls.intersection(seg, isBelongToSegment);
    			if(p!=null)
    				pushPt(p);    			
    		}    		
    	}
    	
    	return arr;
    }   
    
   	public static function rectLineIntersection(rect:Rectangle, ls:LineSegment, isBelongToSegment:Boolean=false):Array
   	{
   		var pt1:Point = rect.topLeft.clone();
   		var pt2:Point = new Point(rect.right, rect.top)
   		var pt3:Point = rect.bottomRight.clone();
   		var pt4:Point = new Point(rect.left, rect.bottom)
   		
   		return polygonLineIntersection(new Polygon([pt1, pt2, pt3, pt4]), ls, isBelongToSegment);
   	}
   	
    public static function size(...args):Rectangle
    {
		var rect:Rectangle;
		
		for(var i:int=0; i<args.length; i++) 
		{
			var obj:Object = args[i];
			
			if(	obj is Array || 
				obj is ListCollectionView)
			{
				obj = size(obj);				
			}			
   			
   			if(obj && obj.hasOwnProperty('x') && obj.hasOwnProperty('y'))
   			{
   				if(rect==null) 
   				{
   					rect = new Rectangle();
	   				rect.left = rect.right = obj.x;
	   				rect.top = rect.bottom = obj.y;
   				}
   				
   				rect.left = 	Math.min(rect.left, 	obj.x);
   				rect.top = 		Math.min(rect.top, 		obj.y);
   				rect.right = 	Math.max(rect.right, 	obj.x);
   				rect.bottom = 	Math.max(rect.bottom, 	obj.y);
	   			
	   			if(obj.hasOwnProperty('width') && obj.hasOwnProperty('height'))
   				{
   					rect.left = 	Math.min(rect.left, 	obj.x + obj.width);
   					rect.top = 		Math.min(rect.top, 		obj.y + obj.height);
   					rect.right = 	Math.max(rect.right, 	obj.x + obj.width);
   					rect.bottom = 	Math.max(rect.bottom, 	obj.y + obj.height);
   				}
   			}
   		}   		   		
   		return rect;
    }
    
    public static function offset(dX:Number, dY:Number, ...args):void
    {
		for(var i:int=0; i<args.length; i++) 
		{
			var obj:Object = args[i];
			
			if(	obj is Array || 
				obj is ListCollectionView)
			{
				offset(dX, dY, obj);				
			}   			
   			else if(obj && obj.hasOwnProperty('x') && obj.hasOwnProperty('y'))
   			{
   				obj.x += dX;
   				obj.y += dY;
   			}
   		}   
    }
    
	public static function diffRect(rect1:Rectangle, rect2:Rectangle):Rectangle
	{
		if(rect1.intersects(rect2))
			return null;
		
   		var union:Rectangle = rect1.union(rect2);
   		
   		if(union.top == rect1.top) {
	   		union.top += Math.min(
   				rect1.bottom-union.top,
   				rect2.top-union.top); 
   		} else {
	   		union.top += Math.min(
   				rect1.top-union.top,
   				rect2.bottom-union.top); 
		}			
		
   		if(union.bottom == rect1.bottom) {
	   		union.bottom -= Math.min(
   				union.bottom-rect1.top,
   				union.bottom-rect2.bottom); 
   		} else {
	   		union.bottom -= Math.min(
   				union.bottom-rect1.bottom,
   				union.bottom-rect2.top); 
		}			

   		if(union.left == rect1.left) {
	   		union.left += Math.min(
   				rect1.right-union.left,
   				rect2.left-union.left); 
   		} else {
	   		union.left += Math.min(
   				rect1.left-union.left,
   				rect2.right-union.left); 
		}			

   		if(union.right == rect1.right) {
	   		union.right -= Math.min(
   				union.right-rect1.left,
   				union.right-rect2.right); 
   		} else {
	   		union.right -= Math.min(
   				union.right-rect1.right,
   				union.right-rect2.left); 
		}			

		return union;
	}
        
}
}