//
// Bezier2.as - Quadratic Bezier.
//
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
// Note:  Set the container reference before calling any drawing methods
//

package Singularity.Geom
{
  import Singularity.Geom.Quad;
  import Singularity.Geom.Parametric;
  
  import Singularity.Numeric.Consts;
  
  import flash.display.Shape;
  import flash.display.Graphics;
  import flash.geom.ColorTransform;
  
  public class Bezier2 extends Parametric
  {
  	// core
    private var __p0X:Number;             // x-coordinate, first control point
    private var __p0Y:Number;             // y-coordinate, first control point
    private var __p1X:Number;             // x-coordinate, second control point
    private var __p1Y:Number;             // y-coordinate, second control point
    private var __p2X:Number;             // x-coordinate, third control point
    private var __p2Y:Number;             // y-coordinate, third control point
    private var __autoParam:Number;       // parameter value from automatic chord-length parameterization during interpolation

    // Subdivision
    private var __cX:Number;              // left-cage control point, x-coordinate
    private var __cY:Number;              // left-cage control point, y-coordinate
    private var __pX:Number;              // subdivision anchor point, x-coordinate
    private var __pY:Number;              // subdivision anchor point, y-coordinate
    
/**
* @description 	Method: Bezier2() - Construct a new Bezier2 instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Bezier2()
    {
      super();
      
      __p0X = 0;
      __p0Y = 0;
      __p1X = 0;
      __p1Y = 0;
      __p2X = 0;
      __p2Y = 0;

      __cX = 0;
      __cY = 0;
      __pX = 0;
      __pY = 0;
      
      __error.classname = "Bezier2";

      __coef      = new Quad();
      __container = null;
    }
    
/**
* @description 	Method: getParam( _seg:uint ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return uint - Adds control points in order called up to to three
*
* @since 1.0
*
*/
    public override function getParam(_seg:uint):Number { return __autoParam;}

/**
* @description 	Method: addControlPoint( _xCoord:Number, _yCoord:Number ) - Add a control point
*
* @param _xCoord:Number - control point, x-coordinate
* @param _yCoord:Number - control point, y-coordinate
*
* @return Nothing - Adds control points in order called up to to three
*
* @since 1.0
*
*/
    public override function addControlPoint( _xCoord:Number, _yCoord:Number ):void
    {
      if( __count == 3 )
      {
        __error.methodname = "addControlPoint()";
        __error.message    = "Point limit exceeded";
        dispatchEvent( __error );
        return;
      }

      switch( __count )
      {
        case 0 :
          __p0X = _xCoord;
          __p0Y = _yCoord;
          __count++;
        break;
      
        case 1 :
          __p1X = _xCoord;
          __p1Y = _yCoord;
          __count++;
        break;
        
        case 2 :
          __p2X = _xCoord;
          __p2Y = _yCoord;
          __count++;
        break;
      }
      __invalidate = true;
    } 

/**
* @description 	Method: moveControlPoint(_indx:uint, _newX:Number, _newY:Number) - Move a control point
*
* @param _indx:Number - Index of control point (0, 1, or 2)
* @param _newX:Number - New x-coordinate
* @param _newY:Number - New y-coordinate
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _newX:Number, _newY:Number):void
    {
      __error.methodname = "moveControlPoint()";
    
      if( _indx < 0 || _indx > 2 )
      {
        __error.message = "Invalid index: " + _indx.toString();
        dispatchEvent(__error);
        return;
      }
 
      if( isNaN(_newX) )
      {
        __error.message = "Invalid x-coordinate.";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_newY) )
      {
        __error.message = "Invalid y-coordinate.";
        dispatchEvent(__error);
        return;
      }
  
      switch( _indx )
      {
        case 0 :
          __p0X = _newX; 
          __p0Y = _newY;
        break;
      
        case 1 :
          __p1X = _newX;
          __p1Y = _newY;
        break;
    
        case 2 :
          __p2X = _newX;
          __p2Y = _newY;
        break;
      }

      __invalidate = true;
    }
  
/**
* @description 	Method: reset() - Reset control points
*
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function reset():void
    {
      __p0X        = 0;
      __p0Y        = 0;
      __p1X        = 0;
      __p1Y        = 0;
      __p2X        = 0;
      __p2Y        = 0;
      __cX         = 0;
      __cY         = 0;
      __pX         = 0;
      __pY         = 0;
      __count      = 0;
      __autoParam  = 0;
      __arcLength  = -1;
      __invalidate = true;
      
      __coef.reset();
    }

/**
* @description 	Method: draw(_t:Number) - Draw the cubic Bezier using a quadratic approximation, based on subdivision
*
* @param _t:Number - parameter value in [0,1]
*
* @return Nothing - arc is drawn in designated container from t=0 to _t
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function draw(_t:Number):void
    {
      if( _t == 0 )
        return;

      var g:Graphics = __container.graphics;
      g.lineStyle(__thickness, __color);

      if( _t >= 1 )
      {
        g.moveTo(__p0X, __p0Y);
        g.curveTo( __p1X, __p1Y, __p2X, __p2Y );
      }
      else if( _t <= 0 )
        g.clear();
      else
	  {
        __subdivide(_t);
	  
	    // plot only segment from 0 to _t
	    g.moveTo(__p0X, __p0Y);
        g.curveTo( __cX, __cY, __pX, __pY );
	  }
    }

/**
* @description 	Method: reColor(_c:Number) - Recolor the quad. curve
*
* @param _c:Number - Hex code for curve color
*
* @return Nothing
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function reColor(_c:Number):void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = _c;
      __container.transform.colorTransform = colorXForm;
    }

/**
* @description 	Method: reDraw() - Redraw the curve with its base color
*
* @return Nothing
*
* @since 1.0
*
* Note:  For performance reasons, no error checking is performed
*
*/
    public override function reDraw():void
    {
      var g:Graphics = __container.graphics;
      
      var colorXForm:ColorTransform = __container.transform.colorTransform;
      colorXForm.color = __color;
      __container.transform.colorTransform = colorXForm;
    }

    private function __subdivide(_t:Number):void
    {
      var t1:Number = 1.0 - _t;

      __cX = _t*__p1X + t1*__p0X;
      __cY = _t*__p1Y + t1*__p0Y;

      var p21X:Number = _t*__p2X + t1*__p1X;
      var p21Y:Number = _t*__p2Y + t1*__p1Y;

      __pX = _t*p21X + t1*__cX;
      __pY = _t*p21Y + t1*__cY;
    }

/**
* @description 	Method: getX( _t:Number ) - Return x-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of Quadratic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public override function getX(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;
    
      if( __invalidate )
        __computeCoef();
 
      __setParam(t);
      return __coef.getX(__t);
    }

/**
* @description 	Method: getY( _t:Number ) - Return y-coordinate for a given t
*
* @param _t:Number - parameter value in [0,1]
*
* @return Number: Value of Quadratic Bezier curve provided input is in [0,1], otherwise return B(0) or B(1).
*
* @since 1.0
*
*/
    public override function getY(_t:Number):Number
    {
      var t:Number = _t;
      t = (t<0) ? 0 : t;
      t = (t>1) ? 1 : t;

      if( __invalidate )
        __computeCoef();

      __setParam(t);
      return __coef.getY(__t);
    }

/**
* @description 	Method: interpolate( _points:Array ) - Compute control points so that quad. Bezier passes through three points
*
* @param _points:Array - array of three Objects with x- and y-coordinates in .X and .Y properties.  These points represent the coordinates of the interpolation points.
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function interpolate(_points:Array):void
    {
      // compute t-value using chord-length parameterization
      var dX:Number = _points[1].X - _points[0].X;
      var dY:Number = _points[1].Y - _points[0].Y;
      var d1:Number = Math.sqrt(dX*dX + dY*dY);
      var d:Number  = d1;

      dX = _points[2].X - _points[1].X;
      dY = _points[2].Y - _points[1].Y;
      d += Math.sqrt(dX*dX + dY*dY);

      var t:Number = d1/d;

      var t1:Number    = 1.0-t;
      var tSq:Number   = t*t;
      var denom:Number = 2.0*t*t1;

      __p0X = _points[0].X;
      __p0Y = _points[0].Y;

      __p1X = (_points[1].X - t1*t1*_points[0].X - tSq*_points[2].X)/denom;
      __p1Y = (_points[1].Y - t1*t1*_points[0].Y - tSq*_points[2].Y)/denom;

      __p2X = _points[2].X;
      __p2Y = _points[2].Y;

      __invalidate = true;
      __autoParam  = t;
    }

    public override function __computeCoef():void
    {
  	  if( __count < 2 )
  	  {
  	    __error.methodname = "__computeCoef()";
  	    __error.message    = "Insufficient number of control points";
  	    dispatchEvent(__error);
  	  }
  	  else
  	  {
  	  	__coef.reset();
        __coef.addCoef( __p0X, __p0Y );

        __coef.addCoef( 2.0*(__p1X-__p0X), 2.0*(__p1Y-__p0Y) );

        __coef.addCoef( __p0X-2.0*__p1X+__p2X, __p0Y-2.0*__p1Y+__p2Y );

        __invalidate = false;
        __arcLength  = -1;
        __parameterize();
      }
    }
  }
}