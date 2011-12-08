package net.vdombox.powerpack.lib.geomlib._3D
{
import flash.geom.Point;

/**
 * 
 * The Point3D object represents a location in a three-dimensional coordinate system, where 
 * <i>x</i> represents the OX axis, 
 * <i>y</i> represents the OY axis and 
 * <i>z</i> represents the OZ axis.
 * 
 * @example The following code creates a point at (0,0,0):
 * <listing version="3.0">var myPoint:Point3D = new Point3D();</listing>
 *  
 * @see flash.geom.Point
 */
public class Point3D extends Object
{
	/**
	 * The x coordinate of the point. 
	 */
	public var x:Number; 
	/**
	 * The y coordinate of the point. 
	 */
	public var y:Number; 
	/**
	 * The z coordinate of the point. 
	 */
	public var z:Number; 
		
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
		
	/**
	 * Creates a new point. If you pass no parameters to this method, a point is created at (0,0,0). 
	 * 
	 * @param x The x coordinate of the point.
	 * @param y The y coordinate of the point.
	 * @param z The z coordinate of the point.
	 * 
	 */
	public function Point3D(x:Number=0, y:Number=0, z:Number=0)
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  length
	//----------------------------------
			
	/**
	 * The length of the line segment from (0,0,0) to this point. 
	 */
	public function get length():Number
	{
		var pXY:Point = new Point(x, y);
		var p:Point = new Point(pXY.length, z);
		
		return p.length;			
	}

 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//-------------------------------------------------------------------------- 
	
	/**
	 * Creates a copy of this Point3D object.
	 * 
	 * @return The new Point3D object.  
	 * 
	 */
	public function clone():Point3D
	{
		return new Point3D(x,y,z);
	}
	
	/**
	 * Adds the coordinates of another point to the coordinates of this point to create a new point.
	 * 
	 * @param v The point to be added.  
	 * @return The new point.  
	 * 
	 */
	public function add(v:Point3D):Point3D
	{
		var p:Point3D = clone();
		
		p.x += v.x;		
		p.y += v.y;		
		p.z += v.z;
		
		return p;		
	}
	
	/**
	 * Subtracts the coordinates of another point from the coordinates of this point to create a new point.
	 * 
	 * @param v The point to be subtracted.
	 * @return The new point.
	 * 
	 */
	public function subtract(v:Point3D):Point3D
	{
		var p:Point3D = clone();
		
		p.x -= v.x;
		p.y -= v.y;		
		p.z -= v.z;
		
		return p;		
	}
	
	/**
	 * Returns the distance between <code>pt1</code> and <code>pt2</code>.
	 *  
	 * @param pt1 The first point.
	 * @param pt2 The second point.  
	 * @return The distance between the first and second points.
	 * 
	 */
	public static function distance(pt1:Point3D, pt2:Point3D):Number
	{
		return pt2.subtract(pt1).length;	
	}
	
	/**
	 * Determines whether two points are equal. Two points are equal if they have the same 
	 * <i>x</i>, <i>y</i> and <i>z</i> values.
	 *   
	 * @param toCompare The point to be compared.
	 * @return A value of <code>true</code> if the object is equal to this Point3D object; 
	 * <code>false</code> if it is not equal.
	 * 
	 */
	public function equals(toCompare:Point3D):Boolean
	{
		return (x==toCompare.x && y==toCompare.y && z==toCompare.z ? true : false)
	}
	
	/**
	 * Determines a point between two specified points. The parameter f determines where the new 
	 * interpolated point is located relative to the two end points specified by parameters 
	 * <code>pt1</code> and <code>pt2</code>. 
	 * The closer the value of the parameter <code>f</code> is to 1.0, the closer 
	 * the interpolated point is to the first point (parameter <code>pt1</code>). 
	 * The closer the value of the parameter <code>f</code> is to 0.0, the closer 
	 * the interpolated point is to the second point (parameter <code>pt2</code>).
	 *   
	 * @param pt1 The first point.
	 * @param pt2 The second point.
	 * @param f The level of interpolation between the two points. Indicates where the new point will 
	 * be, along the line between <code>pt1</code> and <code>pt2</code>. 
	 * If <code>f</code>=1, <code>pt1</code> is returned; if <code>f</code>=0, <code>pt2</code> is returned.
	 * @return The new, interpolated point.  
	 * 
	 */
	public static function interpolate(pt1:Point3D, pt2:Point3D, f:Number):Point3D
	{
		var mnp:Point3D = pt1.subtract(pt2);
		
		mnp.x *= f;
		mnp.y *= f;
		mnp.z *= f;
		
		return pt2.add(mnp);
	}	
	
	/**
	 * Scales the line segment between (0,0,0) and the current point to a set length.
	 * 
	 * @param thickness The scaling value. For example, if the current point is (0,0,5), 
	 * and you normalize it to 1, the point returned is at (0,0,1).
	 * 
	 */
	public function normalize(thickness:Number):void 
	{
		var p0:Point3D = new Point3D(0,0,0);		
		var p:Point3D = Point3D.interpolate(this, p0, thickness/length);
		
		x=p.x;
		y=p.y;
		z=p.z;
	}
	
	/**
	 * Offsets the Point3D object by the specified amount. 
	 * The value of <code>dx</code> is added to the original value of <i>x</i> to create the new <i>x</i> value. 
	 * The value of <code>dy</code> is added to the original value of <i>y</i> to create the new <i>y</i> value. 
	 * The value of <code>dz</code> is added to the original value of <i>z</i> to create the new <i>z</i> value.
	 * 
	 * @param dx The amount by which to offset the OX coordinate, <i>x</i>.
	 * @param dy The amount by which to offset the OY coordinate, <i>y</i>.
	 * @param dz The amount by which to offset the OZ coordinate, <i>z</i>.
	 * 
	 */
	public function offset(dx:Number, dy:Number, dz:Number):void
	{
		this.x += dx;
		this.y += dy;
		this.z += dz;
	}
	
	/**
	 * Returns a string that contains the values of the <i>x</i>, <i>y</i> and <i>z</i> coordinates. 
	 * The string has the form <code>"(x=<i>x</i>, y=<i>y</i>, z=<i>z</i>)"</code>, 
	 * so calling the <code>toString()</code> method 
	 * for a point at 23,17,45 would return <code>"(x=23, y=17, z=45)"</code>. 
	 *  
	 * @return The string representation of the coordinates.  
	 * 
	 */
	public function toString():String
	{
		return "(x="+x+", y="+y+", z="+z+")";
	}
	
}
}