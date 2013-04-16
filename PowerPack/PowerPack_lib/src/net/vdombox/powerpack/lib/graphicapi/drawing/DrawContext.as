package net.vdombox.powerpack.lib.graphicapi.drawing
{
import net.vdombox.powerpack.lib.geomlib._2D.Ellipse;

import Singularity.Geom.BezierSpline;
import Singularity.Geom.CatmullRom;

import flash.display.Graphics;
import flash.geom.Point;

public class DrawContext extends GraphicsContext
{
	public static var gap:uint = 2;

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------	
		
	/**
	 * Constructor.
	 *  
	 * @param graphics
	 * 
	 */
	public function DrawContext(graphics:Graphics)
	{
		super(graphics);
	}       
	 
	//--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------         
	
	/**
	 * Draw parametric arc.
	 *  
	 * @param centerX
	 * @param centerY
	 * @param radiusH Horizontal radius.
	 * @param radiusV Vertical radius.
	 * @param startAngle
	 * @param endAngle
	 * @param arcTo Continue drawing from last pen position. 
	 * @param closed Close figure.
	 * @param gap Drawing gap.
	 * 
	 */
	public function arc(	centerX:Number, 
							centerY:Number, 
							radiusH:Number,
							radiusV:Number,
							angle:Number,		 
							startAngle:Number, 
							endAngle:Number,
							arcTo:Boolean = true,
							closed:Boolean = false,
							gap:Number = 3):void
	{
		if(radiusH<0 || radiusV<0)
			return;
		
		if(startAngle==endAngle)
			return;

		var ellipse:Ellipse = new Ellipse(new Point(centerX, centerY), radiusH, radiusV, -angle/180*Math.PI);		  
		
		var len:Number;
		var step:Number;
		var pt0:Point;
		var pt:Point;
		
		var angleStart:Number = -startAngle / 180 * Math.PI ;
		var angleEnd:Number = -endAngle / 180 * Math.PI;
		gap = gap>0?gap:3;
		
		/* determines how much to increase angle for each pixel plotted */
		len = ellipse.length;
		step = ( 2 * Math.PI ) / ( len / gap );
		
		pt0 = pt = ellipse.calculate(angleStart);
		
		if(arcTo)
			lineTo(pt.x, pt.y, true);
		else
			moveTo(pt.x, pt.y);

		/* Draw a dotted circle, using cos() for the x coordinates, and sin() for the y coordinates. */
		for (var t:Number = angleStart-step; t > angleEnd; t -= step) 
		{
			pt = ellipse.calculate(t);
			lineTo(pt.x, pt.y);
		}

		pt = ellipse.calculate(angleEnd);		
		lineTo(pt.x, pt.y, true);
		
		if(closed)
			lineTo(pt0.x, pt0.y, true);
	}

	/**
	 * Draw bezier spline.
	 * 
	 * @param points
	 * @param drawTo Continue drawing from last pen position.
	 * 
	 */
	public function bezierSpline(	points:Array,
									drawTo:Boolean = true):void
	{
		var spline:BezierSpline = new BezierSpline();
		
		for(var i:int=0; i<points.length; i++) {
			spline.addControlPoint(points[i].x, points[i].y);
		}
		
		var len:Number = spline.arcLength();
		
		var deltaT:Number = 2/len;
		
		if(drawTo)
			lineTo(points[0].x, points[0].y);
		else
			moveTo(points[0].x, points[0].y);

		for( var t:Number=deltaT; t<=1; t+=deltaT )
			lineTo(spline.getX(t), spline.getY(t), t>=1?true:false);

	}	

	/**
	 * Draw Catmull-Rom spline.
	 * 
	 * @param points
	 * @param drawTo Continue drawing from last pen position.
	 * 
	 */
	public function catmullRom(		points:Array,
									drawTo:Boolean = true):void
	{
		var spline:CatmullRom = new CatmullRom();
		//spline.parameterize = Consts.ARC_LENGTH
		//spline.tangent = Consts.AUTO;
		
		for(var i:int=0; i<points.length; i++) {
			spline.addControlPoint(points[i].x, points[i].y);
		}
		
		var len:Number = spline.arcLength();
		
		var deltaT:Number = 2/len;
		
		if(drawTo)
			lineTo(points[0].x, points[0].y);
		else
			moveTo(points[0].x, points[0].y);

		for( var t:Number=deltaT; t<=1; t+=deltaT )
			lineTo(spline.getX(t), spline.getY(t), t>=1?true:false);

	}
						
	/**
	 * Draw cubic bezier.
	 * 
	 * @param x0
	 * @param y0
	 * @param x1
	 * @param y1
	 * @param x2
	 * @param y2
	 * @param x3
	 * @param y3
	 * @param bezierTo Continue drawing from last pen position.
	 * 
	 */
	public function cubicBezier(	x0:Number,y0:Number,
	    							x1:Number,y1:Number,
	    							x2:Number,y2:Number,
	    							x3:Number,y3:Number,
									bezierTo:Boolean = true):void
	{
		var t:Number;
		var dt:Number = 0.01;
		var a:Array = new Array(4);
		var b:Array = new Array(4);
		
		a[3]=(-x0+3*x1-3*x2+x3)/6;
		a[2]=(3*x0-6*x1+3*x2)/6;
		a[1]=(-3*x0+3*x2)/6;
		a[0]=(x0+4*x1+x2)/6;

		b[3]=(-y0+3*y1-3*y2+y3)/6;;
		b[2]=(3*y0-6*y1+3*y2)/6;
		b[1]=(-3*y0+3*y2)/6;
		b[0]=(y0+4*y1+y2)/6;
		
		var x:Number = a[0];
		var y:Number = b[0];
		
		if(bezierTo)
			lineTo(x, y);
		else
			moveTo(x, y);

		t=0;
		while(t<1)
		{
  			t=t+dt;
  			
  			x = a[0] + (a[1] + (a[2] + a[3]*t)*t)*t;  
  			y = b[0] + (b[1] + (b[2] + b[3]*t)*t)*t;  
  			
  			lineTo(x, y, t>=1?true:false);
		}
	}    
	
	/**
	 * Draw quadratic bezier from last pen position.
	 * @param x1
	 * @param y1
	 * @param x2
	 * @param y2
	 * 
	 */
	public function  quadraticBezierTo(	x1:Number,y1:Number,
		    							x2:Number,y2:Number):void
	{
		var t:Number;
		var dt:Number = 0.01;
		
		var x0:Number =	position.x;		
		var y0:Number = position.y;
		var x:Number = x0;
		var y:Number = y0;		
		
		t=0;
		while(t<1)
		{
  			t=t+dt;
	
			var a:Number = (1-t)*(1-t); 
			var b:Number = 2*t*(t-1); 
  			var c:Number = t*t;
  			
  			x = a*(x0) + b*(-x1) + c*(x2);
  			y = a*(y0) + b*(-y1) + c*(y2);

  			lineTo(x, y, t>=1?true:false);
		}
	}
		
    /**
     * Change current pen position.
     *  
     * @param x
     * @param y
     * 
     */
    public function moveTo(x:Number,y:Number):void
    {
    	position = new Point(x,y);
    	stroke.refreshPattern();
   	    graphics.moveTo(x, y);
    }  
	
	/**
	 * Draw line.
	 * 
	 * @param x
	 * @param y
	 * @param forced Ignore gap settings when reach end of line.
	 * 
	 */
	public function lineTo(		x:Number, y:Number, 
								forced:Boolean=false ):void
    {
    	var g:Graphics = this.graphics;
        var stroke:PStroke = this.stroke;
        var p1:Point = this.position;            
        var p2:Point = new Point(x, y);   
        var gap:Number = DrawContext.gap<1?1:DrawContext.gap;
    	
        var dX:Number = p2.x - p1.x;
        var dY:Number = p2.y - p1.y;
        var len:Number = Point.distance(p1, p2);
		
		if(len<gap && !forced || len==0)
			return;
		
        if(!stroke.pattern || stroke.pattern.length==0)
        {
        	stroke.visible = false;
        	_solidLineTo(p2.x, p2.y);
        	return;
        }
        
        if(stroke.pattern.length==1 && stroke.pattern[0]==0)
        {
        	stroke.visible = true;
			_solidLineTo(p2.x, p2.y);
        	return;
        }
        
        dX /= len;
        dY /= len;
        var tMax:Number = len;            
        
        var t:Number = -stroke.offset;
        var bDrawing:Boolean = stroke.drawing;
        var patternIndex:int = stroke.patternIndex;
        while(t < tMax)
        {
            t += stroke.pattern[patternIndex];
            if(t >= tMax)
            {
                stroke.offset = stroke.pattern[patternIndex] - (t - tMax);
                stroke.patternIndex = patternIndex;
                stroke.drawing = bDrawing;
                t = tMax;
            }
            
            if(bDrawing)
            	stroke.visible = true;
            else
            	stroke.visible = false;

            _solidLineTo(p1.x + t*dX, p1.y + t*dY);

            bDrawing = !bDrawing;
            patternIndex = (patternIndex + 1) % stroke.pattern.length;
        }
    }        
            
    /**
     * @private 
     */
    private function _solidLineTo(x:Number,y:Number):void
    {
    	this.position = new Point(x,y);
   	    this.graphics.lineTo(x, y);
    }
	
}
}