package GeomLib._2D
{
import flash.geom.Point;

public class Circle extends Ellipse
{
	public function Circle(center:Point, radius:Number)
	{
		super(center, radius, radius, 0.0);
	}
	
	public function get radius():Number
	{
		return a;
	}	
	public function set radius(value:Number):void
	{
		a = value;
		b = value;
	}		
}
}