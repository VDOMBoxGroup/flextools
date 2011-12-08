package net.vdombox.powerpack.lib.geomlib._2D
{

import net.vdombox.powerpack.lib.geomlib.GeomUtils;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * The LineSegment object represents a line segment in a two-dimensional coordinate system, 
 * where p1 and p2 represents its ends. 
 */
public class LineSegment extends Object 
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
		
	/**
	 * Constructor.
	 * 
	 * @param p1 1st end point.
	 * @param p2 2nd end point.
	 * 
	 */
	public function LineSegment(p1:Point, p2:Point)		
	{
		this.p1 = p1;	
		this.p2 = p2;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------	

	/**
	 * 1st end point. 
	 */
	public var p1:Point;
	
	/**
	 * 2nd end point. 
	 */
	public var p2:Point;	
	
	//----------------------------------
	//  equationCoefs: ax + by + c = 0
	//----------------------------------
	
    /**
     * Returns <code>{a, b, c}</code>, where <code>a</code>, <code>b</code>, <code>c</code> 
     * are coefficients of the following line equation: 
     * <code>ax + by + c = 0</code>.
     */
    public function get equationCoefs():Object
    {
    	var precision:Number = 0.0000000001;
    	
    	// ax + by + c = 0
     	var a:Number = (p2.y - p1.y);
	    var b:Number = -(p2.x - p1.x);
	    var c:Number = -(a*p1.x + b*p1.y); 
	    
	    a = Math.round(a/precision)*precision;
	    b = Math.round(b/precision)*precision;
	    c = Math.round(c/precision)*precision;
	    
	    var coef:Number = Math.max(Math.abs(a), Math.abs(b), Math.abs(c));    
	    
	    if(coef>1)
	    {
			a = a/coef;
			b = b/coef;
			c = c/coef;		
	    }
	    
	    return {a:a, b:b, c:c};
    }	
    
    /**
     * Returns <code>{m, n}</code>, where <code>m</code>, <code>n</code> 
     * are coefficients of the following parametric line equations: 
     * <code>x = x0 + <i>m</i>t</code>,
     * <code>y = y0 + <i>n</i>t</code>.
     * <code>t = [0..1]</code>
     */
    public function get paramEquationCoefs():Object
    {
    	var mn:Point = p2.subtract(p1);
    	return {m:mn.x, n:mn.y}; 
    }
        
	public function get left():Point	{ return (p1.x<=p2.x ? p1 : p2); }
	public function get top():Point		{ return (p1.y<=p2.y ? p1 : p2); }
	public function get right():Point	{ return (p2.x>=p1.x ? p2 : p1); }
	public function get bottom():Point	{ return (p2.y>=p1.y ? p2 : p1); }
	public function get center():Point	{ return interpolate(0.5); }	
    public function get length():Number	{ return Point.distance(p2, p1); }    
    
    public function get size():Rectangle
    {
    	var tl:Point = new Point( Math.min(p1.x, p2.x), Math.min(p1.y, p2.y));
    	var br:Point = new Point( Math.max(p1.x, p2.x), Math.max(p1.y, p2.y));
    	
    	var size:Rectangle = new Rectangle();
    	size.topLeft = tl; 
    	size.bottomRight = br; 
    	
    	return size; 
    }

    public function get perpendicular():LineSegment
    {
    	var matrix:Matrix = new Matrix();
    	
    	var pc:Point = center;
    	var pt1:Point = p1.clone();
    	var pt2:Point = p2.clone();    	
    	
		matrix.translate(-pc.x, -pc.y);
    	matrix.rotate(Math.PI/2);
    	
		pt1 = matrix.transformPoint(pt1);
		pt2 = matrix.transformPoint(pt2);

		pt1 = pt1.add(pc);
		pt2 = pt2.add(pc);

    	return new LineSegment(pt1, pt2);
    }
    
 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------    
    
	public function clone():LineSegment
	{		
		return new LineSegment(p1.clone(), p2.clone()); 		
	}
	
	public function isEmpty():Boolean
	{
		return p1.equals(p2);		
	}
	
	public function setEmpty():void
	{
		p1 = new Point(0,0);
		p2 = new Point(0,0);
	}
	
	public function equals(toCompare:LineSegment, strict:Boolean=true):Boolean
	{
		if(p1.equals(toCompare.p1) && p2.equals(toCompare.p2))
			return true;
			
		if(!strict && p1.equals(toCompare.p2) && p2.equals(toCompare.p1))
			return true;
			
		return false; 
	}
	
	public function offset(dx:Number, dy:Number):void
	{
		p1.offset(dx, dy);
		p2.offset(dx, dy);
	}
	
	public function inflate(dx:Number, dy:Number):void
	{
		var pc:Point = center;
		var sz:Rectangle = size;
		var matrix:Matrix = new Matrix();
		
		offset(-pc.x, -pc.y);		
		
		matrix.scale( (dx+sz.width)/sz.width, (dy+sz.height)/sz.height );		
		
		p1 = matrix.transformPoint(p1);
		p2 = matrix.transformPoint(p2);

		offset(pc.x, pc.y);		
	}
	
	public function interpolate(f:Number):Point
	{
		return Point.interpolate(p1, p2, f); 	
	}

	/**
	 * 
	 * Get matrix that transforms given line segment to line segment with 
	 * coordinates <code>(0,0) (0,length)</code>,
	 * where <code>length</code> is the length of the given line segment.
	 * 
	 * @return Transformation matrix.
	 * 
	 */
	public function toVerticalMatrix():Matrix
	{
		var matrix:Matrix = new Matrix();
		
		var angle:Number = GeomUtils.angle(p2.subtract(p1));
		
		matrix.translate(-p1.x, -p1.y);
		matrix.rotate(-angle + Math.PI/2);
		
		return matrix;
	}
	
	/**
	 * Shifts line segment in a given direction.
	 * 
	 * @param distance Shift distance. 
	 * @param direction Possible shift direction values:
	 * <ul>
	 * 	<li><code>'l'</code> (left)</li>
	 * 	<li><code>'r'</code> (right)</li>
	 * 	<li><code>'f'</code> (forward)</li>
	 * 	<li><code>'b'</code> (backward)</li>
	 * </ul>
	 * @return New line segment.
	 * 
	 */
	public function shift(distance:Number, direction:String):LineSegment
	{
		var matrix:Matrix = toVerticalMatrix();			
		
		var np1:Point = matrix.transformPoint(p1);
		var np2:Point = matrix.transformPoint(p2);

		matrix.invert();

		switch(direction)
		{
			case 'f':
				np1.y += distance; 			
				np2.y += distance;
				break;		
			case 'b':
				np1.y -= distance; 			
				np2.y -= distance;
				break;		
			case 'l':
				np1.x -= distance; 			
				np2.x -= distance;
				break;		
			case 'r':
				np1.x += distance; 			
				np2.x += distance;
				break;
		}		

		np1 = matrix.transformPoint(np1);
		np2 = matrix.transformPoint(np2);
		
		return new LineSegment(np1, np2); 			
	}
	
	public function transform(matrix:Matrix):LineSegment
	{
		var pt1:Point = matrix.transformPoint(p1);
		var pt2:Point = matrix.transformPoint(p2);
		var seg:LineSegment = new LineSegment(pt1, pt2);
		
		return seg;
	}
	
	public function pointDistance(point:Point):Number
	{
		var matrix:Matrix = toVerticalMatrix();			
		var p:Point = matrix.transformPoint(point);
		
		return p.x;
	}
	
	/**
	 * Method determines which half-plane relative to the line segment a given point belong to.
	 *  
	 * @param point
	 * @param precision
	 * @return The letter that determines point side.
	 * Possible return values:
	 * <ul>
	 * 	<li><code>'l'</code> (left)</li>
	 * 	<li><code>'r'</code> (right)</li>
	 *  <li><code>null</code> (point lays on the line)</li>
	 * </ul>
	 * 
	 */
	public function pointSide(point:Point, precision:Number=0.01):String
	{
		var dx:Number = pointDistance(point);				
		return (dx<-precision ? 'l' : dx>precision ? 'r' : null);
	}
	
	/**
	 * 
	 * @param point
	 * @param precision
	 * @return 
	 * 
	 */
	public function containsPoint(point:Point, precision:Number=0.001):Boolean
	{
		if(pointSide(point)!=null)
			return false;
		
		if(length+precision < Point.distance(point, p1)+Point.distance(point, p2))
			return false;
			
		return true;
	}
   
    /**
     * Method determines cross point of two lines.
     * 
     * @param seg Line segment.
     * @param precision
     * @return Cross point.
     * 
     */
    public function lineIntersection(toIntersect:LineSegment, precision:Number=0.0000001):Point
    {
    	var args1:Object = equationCoefs;
    	var args2:Object = toIntersect.equationCoefs;
    	var point:Point = new Point();       
    	
    	var	condition:Number = (args1.a*args2.b - args2.a*args1.b);
		
		if(Math.abs(condition)<=precision)
			return null;
			
		point.x = (args1.b*args2.c - args2.b*args1.c) / condition; 
		point.y = (args1.c*args2.a - args2.c*args1.a) / condition;
		 
		return point;        	
    }        

    public function intersection(intersectToSeg:LineSegment, isBelongTo:Boolean=true, precision:Number=0.0000001):Point
    {
    	var point:Point = lineIntersection(intersectToSeg, precision);
    	
    	if(point==null)
    		return null;    
    	
    	if((isBelongTo && containsPoint(point) || !isBelongTo) && intersectToSeg.containsPoint(point))    	
			return point;
			
		return null;
    }

	        	
}
}