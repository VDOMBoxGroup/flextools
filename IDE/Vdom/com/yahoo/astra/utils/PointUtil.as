/*
Copyright (c) 2008 Yahoo! Inc.  All rights reserved.  
The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license
*/
package com.yahoo.astra.utils
{
	import flash.geom.Point;
	
	/**
	 * Utility functions for the manipulation of Points.
	 * 
	 * @see flash.geom.Point
	 * 
	 * @author Josh Tynjala
	 */
	public class PointUtil
	{
		/**
		 * Calculates the distance between two points.
		 * 
		 * @param p1	the first point
		 * @param p2	the second point
		 * @return		the calculated distance between the input points
		 */
		public static function distance(p1:Point, p2:Point):Number
		{
			var dx:Number = p1.x - p2.x;
			var dy:Number = p1.y - p2.y;
			
			return Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));
		}
		
		/**
		 * Converts a point in the polar coordinate space to a cartesian (x,y) point.
		 * 
		 * @param radians		the angle of the polar point
		 * @param distance		the distance of the polar point from the origin
		 * @return				the converted Point
		 */
		public static function polarToXY(radians:Number, distance:Number):Point
		{
			var point:Point = new Point();
			point.x = distance * Math.cos(radians);
			point.y = distance * Math.sin(radians);
			return point;
		}

		/**
		 * Determines the angle between two arbitrary points.
		 * 
		 * @param p1	the first point
		 * @param p2	the second point
		 * @return		the angle in radians 
		 */
		public static function angle(p1:Point, p2:Point):Number
		{
			var dx:Number = p1.x - p2.x;
			var dy:Number = p1.y - p2.y;
			return Math.atan2(dy, dx);
		}

	}
}