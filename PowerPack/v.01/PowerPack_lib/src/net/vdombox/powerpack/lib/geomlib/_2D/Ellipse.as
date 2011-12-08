package net.vdombox.powerpack.lib.geomlib._2D
{
import net.vdombox.powerpack.lib.geomlib.GeomUtils;

import flash.geom.Matrix;
import flash.geom.Point;

public class Ellipse extends Object
{
	public var center:Point;
	public var a:Number;	
	public var b:Number;
	
	/**
	 * The rotation angle (in radians).
	 */
	public var angle:Number; 

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
		
	/**
	 * 
	 * @param center
	 * @param a
	 * @param b
	 * @param angle
	 * 
	 */
	public function Ellipse(center:Point, a:Number, b:Number, angle:Number=0.0)
	{
		this.center = center;
		this.a = a;
		this.b = b;
		this.angle = angle;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	/**
	 * Semimajor axis. 
	 */
	public function get A():Number	{ return Math.max(a, b); }
	/**
	 * Semiminor axis.
	 */
	public function get B():Number	{ return Math.min(a, b); }
	/**
	 * Linear eccentricity. <code>c</code> equals the distance from the center to either focus.
	 */
	public function get c():Number	{ return Math.sqrt(A*A - B*B); }
	
	/**
	 * Foci points. 
	 */
	public function get F1F2():Object
	{
		var len:Number = c;
		var F1:Point = Point.polar(len, angle+Math.PI).add(center);
		var F2:Point = Point.polar(len, angle).add(center);
		
		return {F1:F1, F2:F2};
	}
	
	/**
	 * Circumference of the ellipse. 
	 */
	public function get length():Number
	{
		var a_b2:Number = Math.pow((a-b)/(a+b), 2); 
		var m:Number = 1 + (3*a_b2) / (10 + Math.sqrt(4 - 3*a_b2));
		
		return Math.PI * (a + b) * m; 
	}
	
	public function get area():Number
	{
		return Math.PI * a * b; 
	}

    // TODO: public function get size():Rectangle

    // TODO: public function get equationCoefs():Object

    public function get paramEquationCoefs():Object
    {
    	return {a:a, b:b, cosa:Math.cos(angle), sina:Math.sin(angle)};
    }
    	
 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	public function clone():Ellipse
	{
		return new Ellipse(center.clone(), a, b, angle);		
	}
	
	public function offset(dx:Number, dy:Number):void
	{
		center.offset(dx, dy);
	}

    public function inflate(da:Number, db:Number):void
    {
    	a += da; 
    	b += db; 
    }
	
	public function transform(matrix:Matrix):Ellipse
	{
		var ff:Object = F1F2;
		var pA:Point = Point.polar(a, angle).add(center);
		var pB:Point = Point.polar(b, angle + Math.PI/2).add(center);

		var pc:Point = matrix.transformPoint(center);
		var f1:Point = matrix.transformPoint(ff.F1);
		var f2:Point = matrix.transformPoint(ff.F2);
		pA = matrix.transformPoint(pA);
		pB = matrix.transformPoint(pB);
				
		var e:Ellipse = clone(); 
		e.center = pc;
		e.a = pA.subtract(pc).length; 
		e.b = pB.subtract(pc).length;
		e.angle = GeomUtils.angle(f2.subtract(f1));
		
		return e;
	}
	
	public function containsPoint(point:Point, precision:Number=0.001):Boolean
	{
		var _pt:Point = point.subtract(center);
		var _angle:Number = GeomUtils.angle(_pt);
		
		if(Point.distance(calculate(_angle), center) + precision > _pt.length)
			return true;
			
		return false;   		
	}
	
	public function calculate(t:Number):Point
	{
		// t=[0..2*PI]
		var c:Object = paramEquationCoefs;
		var sint:Number = Math.sin(t);
		var cost:Number = Math.cos(t);
 
		var x:Number = center.x + (c.a * cost * c.cosa - c.b * sint * c.sina);
		var y:Number = center.y + (c.b * sint * c.cosa + c.a * cost * c.sina);		
		
		return new Point(x, y);
	}
	
	public function equals(toCompare:Ellipse):Boolean
	{
		if(!center.equals(toCompare.center))
			return false;

		if(A!=toCompare.A || B!=toCompare.B)
			return false;
		
		if((angle%360+360)%360 != (toCompare.angle%360+360)%360 && a!=b)
			return false;
		
		return true;  
	}

    // TODO: public function intersection(toIntersect:Ellipse):Array; 
    
    public function isEmpty():Boolean
    {
    	return (a==0 || b==0);    	
    }
    
    public function setEmpty():void
    {
    	center.x=0;
    	center.y=0;
    	a=0;
    	b=0;
    	angle=0.0;
    }	
}
}