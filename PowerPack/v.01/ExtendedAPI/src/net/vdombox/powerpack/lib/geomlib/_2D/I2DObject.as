package src.net.vdombox.powerpack.lib.geomlib._2D
{
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
	
public interface I2DObject
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
		
    function get length():Number;
    
    function get size():Rectangle;

    function get area():Number;

    function get equationCoefs():Object;

    function get paramEquationCoefs():Object;
     
 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//-------------------------------------------------------------------------- 
    
    function clone():Object;
    
    function offset(dx:Number, dy:Number):void;
    
    function inflate(dx:Number, dy:Number):void;

    function transform(matrix:Matrix):Object;
    
    function containsPoint(point:Point, precision:Number=0.001):Boolean;
    
    function equals(toCompare:Object):Boolean;    
    
    function intersection(toIntersect:Object):Object; 
    
    function isEmpty():Boolean;
    
    function setEmpty():void;
    
}
}