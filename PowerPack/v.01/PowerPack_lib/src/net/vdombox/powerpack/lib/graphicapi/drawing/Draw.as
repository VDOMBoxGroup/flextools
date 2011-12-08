package net.vdombox.powerpack.lib.graphicapi.drawing
{

import net.vdombox.powerpack.lib.geomlib.GeomUtils;
import net.vdombox.powerpack.lib.geomlib._2D.Ellipse;
import net.vdombox.powerpack.lib.geomlib._2D.LineSegment;

import net.vdombox.powerpack.lib.graphicapi.GraphicUtils;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Dictionary;

final public class Draw
{
	private static var _contextStack:Dictionary = new Dictionary(true);	

    public static function applyStroke(	target:Object, stroke:PStroke):*
    {
    	arguments.unshift(_applyStroke);
    	return processGraphicObject.apply(null, arguments);
    }	
    
    public static function moveTo(	target:Object,
                                    x:Number,y:Number):*
    {
    	arguments.unshift(_moveTo);
    	return processGraphicObject.apply(null, arguments);
    }	
    
    public static function lineTo(	target:Object,
                                    x:Number,y:Number):*
    {
    	arguments.unshift(_lineTo);
    	return processGraphicObject.apply(null, arguments);
    }
    
    public static function curveTo(	target:Object,
										controlX:Number,
										controlY:Number,
										anchorX:Number,
										anchorY:Number):*
	{
    	arguments.unshift(_curveTo);
    	return processGraphicObject.apply(null, arguments);    	
    }

    public static function polygon(	target:Object, points:Array):*
    {
    	arguments.unshift(_polygon);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function rect(	target:Object,
    								left:Number, top:Number,
    								width:Number, height:Number):*
    {
    	arguments.unshift(_rect);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function roundPolygon(	target:Object,
	    									points:Array,
        									radius:Number=20):*
    {
    	arguments.unshift(_roundPolygon);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function roundRect(	target:Object,
    									left:Number, top:Number,
    									width:Number, height:Number,
    									radius:Number=20):*
    {
    	arguments.unshift(_roundRect);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function arc(	target:Object,
   									x:Number,y:Number, 
									startAngle:Number,endAngle:Number,
									radiusH:Number, radiusV:Number=0.0,
									angle:Number=0.0,
									closed:Boolean=true):*
    {
    	arguments.unshift(_arc);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function pie(	target:Object,
   									x:Number, y:Number, 
									startAngle:Number, endAngle:Number,
									radiusH:Number, radiusV:Number=0.0,
									angle:Number=0.0):*
    {
    	arguments.unshift(_pie);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function circle(	target:Object,
   									x:Number,y:Number,
   									radius:Number):*
    {
    	arguments.unshift(_circle);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function ellipse(	target:Object,
    									x:Number,y:Number,
    									width:Number,height:Number,
    									angle:Number=0.0):*
    {
    	arguments.unshift(_ellipse);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function catmullRom( target:Object, points:Array ):*
    {
    	arguments.unshift(_catmullRom);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function polyBezier( target:Object, points:Array ):*
    {
    	arguments.unshift(_polyBezier);
    	return processGraphicObject.apply(null, arguments);
    }

	public static function closedBezier( target:Object, points:Array ):*
    {
    	arguments.unshift(_closedBezier);
    	return processGraphicObject.apply(null, arguments);
    }

	//--------------------------------------------------------------------------
    //
    //  Private methods
    //
    //-------------------------------------------------------------------------- 
        	
    /**
     * @private
     */
    private static function processGraphicObject(func:Function, ...args):*
    {
    	if(args[0] is Graphics)
    	{
    		func.apply(null, args);
    		return args[0];
    	}
    	else if(args[0] is BitmapData)
    	{
    		var bitmapData:BitmapData = args[0];        		
			var shape:Shape = new Shape();
			
			args[0] = shape.graphics;
			
			func.apply(null, args);
			
			bitmapData.draw(shape);
			
			return bitmapData;
    	}
    	else if(args[0] is DisplayObject)
    	{
    		var displayObj:DisplayObject = args[0];
			bitmapData = new BitmapData(displayObj.width, displayObj.height, true, 0x00000000);
			bitmapData.draw(displayObj);
			
			shape = new Shape();

			args[0] = shape.graphics;
			
			func.apply(null, args);
			
			bitmapData.draw(shape);
			
			return bitmapData;			
    	}
    	else
    	{
    		throw new Error("Not valid target argument");
    	}
    }

    /**
     * @private 
     */
    private static function getGraphicsContext(g:Graphics):DrawContext
    {
    	if(!g) {
   			throw new Error("Graphics object undefined");
    	}    	
    	
    	if(!_contextStack[g])
	    	_contextStack[g] = new DrawContext(g);

   		return _contextStack[g];
    }
    
    /**
     * @private
     * 
     * Fix polygon`s points values.
     * 
     * @param points
     * @param shift Shift distance.
     * @return {points, inside}.
     * 
     */
    private static function processPoints( 	points:Array,
    										shift:Number=0):Object
    {
    	var index:int;
    	var arr:Array = [];
    	var inside:String;
    	var len:int = points.length;
    	        	
    	for(index=0; index<len; index++)
    	{
    		var ls:LineSegment = new LineSegment(points[index], points[(index+1)%len]);
    		inside = ls.pointSide(points[(index+2)%len]);
    		if(inside)
    			break;
    	}

    	if(!inside)
        	return {points:null, inside:null};

    	for(var i:int=index; i<len+index; i++)
    	{
    		var j:int=0;
    		do
    		{
    			var line1:LineSegment = new LineSegment(points[i%len], points[(i+1)%len]);
    			var line2:LineSegment = new LineSegment(points[(i+1)%len], points[(i+2+j)%len]);
			
				if(shift!=0)
				{
    				line1 = line1.shift(shift, inside);
    				line2 = line2.shift(shift, inside);
				}
    		
    			var p:Point = line1.lineIntersection(line2);    			
    			j++;
    			
    		} while(!p && (i%len)!=((i+2+j)%len))
    		
    		if(p)
        		arr.push(p);
    	}
        return {points:arr, inside:inside};
    }	
    
    /**
     * @private
     * 
     * Fix angles values and order.
     * 
     * @param startAngle
     * @param endAngle
     * @return {startAngle, endAngle}.
     * 
     */
    private static function processAngles(	startAngle:Number, 
											endAngle:Number):Object
	{
		var obj:Object = {}; 
		
		if(Math.abs(endAngle-startAngle)>=360.0)
		{
			startAngle = 0.0
			endAngle = 360.0;
		}
		
		if(Math.abs(startAngle)!=360.0)
			startAngle = startAngle%360;
			
		if(Math.abs(endAngle)!=360.0)
			endAngle = endAngle%360;
		
		if(startAngle>endAngle)
		{
			var tmp:Number = startAngle;
			startAngle = endAngle;
			endAngle = tmp;
		}
		
		obj.startAngle = startAngle;
		obj.endAngle = endAngle;
		
		return obj;
	}
	
    /**    
     * @private
     *   
     * Fix arc or pie params values.
     * 
     * @param shift Shift distance.
     * @return {radiusH, radiusV, startAngle, endAngle, center}. 
     * 
     */
    private static function processArcPie(		shift:Number,
												radiusH:Number,
												radiusV:Number,
												angle:Number,        								 
												startAngle:Number, 
												endAngle:Number,
												closed:Boolean = false,
												isPie:Boolean = false):Object
	{
		var obj:Object = {}; 
		
		var objAngles:Object = processAngles(startAngle, endAngle);
		var angleRad:Number = angle / 180 * Math.PI;
		var ellipse:Ellipse = new Ellipse(new Point(0,0), radiusH, radiusV, 0);
		
		ellipse.inflate(-shift, -shift);
		
		obj.radiusH = radiusH - shift;
		obj.radiusV = radiusV - shift;
		obj.startAngle = objAngles.startAngle;
		obj.endAngle = objAngles.endAngle;
		obj.center = new Point(0, 0);
		obj.isDrawing = true;
    	
    	if(shift>0 && (closed || isPie) && obj.startAngle!=obj.endAngle)
    	{
			var angleStart:Number = obj.startAngle / 180 * Math.PI;
			var angleEnd:Number = obj.endAngle / 180 * Math.PI;
			
			var p0:Point = ellipse.calculate(angleStart);
			var pe:Point = ellipse.calculate(angleEnd);

			var ls:LineSegment = new LineSegment(p0.clone(), pe.clone());			
			var ls1:LineSegment = new LineSegment(p0.clone(), new Point(0,0));
			var ls2:LineSegment = new LineSegment(new Point(0,0), pe.clone());
			
		    var p1:Point;
		    var p2:Point;

			if(isPie)
			{
				obj.isDrawing = false;
				ls = ls.shift(shift, 'r');
				ls1 = ls1.shift(shift, 'r');
				ls2 = ls2.shift(shift, 'r');
				
				var p:Point = ls1.lineIntersection(ls2);				
				obj.center = p ? p : ls.center;
				
				if(ellipse.containsPoint(obj.center))
				{
					var pts1:Array = GeomUtils.ellipseLineIntersection(ellipse, ls1, false); 
					var pts2:Array = GeomUtils.ellipseLineIntersection(ellipse, ls2, false);					
								
					if(pts1.length>0) {
					    if(Point.distance(p0, pts1[0]) < Point.distance(p0, pts1[pts1.length-1]))
					    	p1 = pts1[0];
					    else
				    		p1 = pts1[pts1.length-1];    	
					}				
	
					if(pts2.length>0) {
					    if(Point.distance(pe, pts2[0]) < Point.distance(pe, pts2[pts2.length-1]))
					    	p2 = pts2[0];
					    else
				    		p2 = pts2[pts2.length-1];    	
					}				
				
				}
			}
			else
			{
				obj.isDrawing = false;
				ls = ls.shift(shift, 'r');
				
				var pts:Array = GeomUtils.ellipseLineIntersection(ellipse, ls); 
			    
			    if(pts.length>0) 
			    {
			    	if(Point.distance(p0, pts[0]) < Point.distance(p0, pts[pts.length-1])) {
				    	p1 = pts[0];
				    	p2 = pts[pts.length-1];
				    }
				    else {
				    	p1 = pts[pts.length-1];				    	
				    	p2 = pts[0];
				    }
			    }
			    
				if(Math.abs(objAngles.endAngle - objAngles.startAngle)>=360)
					obj.isDrawing = true;
			}			
			
			if(p1 && p2)
			{
				obj.isDrawing = true;
				var matrix:Matrix = new Matrix();
				matrix.rotate(angleRad);
			    obj.center = matrix.transformPoint(obj.center); 
			    
			    matrix.identity();
			    matrix.scale(1, obj.radiusH/obj.radiusV);
			    
			    p1 = matrix.transformPoint(p1);
			    p2 = matrix.transformPoint(p2);
			    
			    obj.startAngle = GeomUtils.angle(p1) / Math.PI * 180;
				obj.endAngle = GeomUtils.angle(p2) / Math.PI * 180;
				
				if(obj.startAngle>obj.endAngle) {
					obj.startAngle -=360;
				}
			}
    	}
    	
    	return obj;
    }

	//--------------------------------------------------------------------------
    //
    //  Drawing methods
    //
    //-------------------------------------------------------------------------- 
                
    /**
     * @private 
     */
    private static function _applyStroke(g:Graphics, stroke:PStroke):void
    {
    	var context:DrawContext = getGraphicsContext(g);
    	context.stroke = stroke;        	      	
    }

    /**
     * @private 
     */
	private static function _moveTo(	g:Graphics,
                            	    x:Number,y:Number):void
    {
    	var context:DrawContext = getGraphicsContext(g);
   	    context.moveTo(x, y);
    }

    /**
     * @private 
     */
	private static function _lineTo(	g:Graphics,
                            	    x:Number,y:Number):void
    {
    	var context:DrawContext = getGraphicsContext(g);
    	context.lineTo(x, y, true);
    }

    /**
     * @private 
     */
	private static function _curveTo(	g:Graphics,
										controlX:Number, 
										controlY:Number, 
										anchorX:Number, 
										anchorY:Number):void
	{
		var context:DrawContext = getGraphicsContext(g);
		
		context.quadraticBezierTo(	controlX, controlY,
						 			anchorX, anchorY);
	}

    /**
     * @private 
     */
	private static function _polygon(	g:Graphics,
    									points:Array):void
    {        	
    	var context:DrawContext = getGraphicsContext(g);
    	var newPoints:Array = GraphicUtils.processPointArray(points);
    	
    	if(newPoints.length<3)
    		return;

    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    		newPoints = processPoints(newPoints, context.stroke.weight/2).points;
    	else
    		newPoints = processPoints(newPoints).points;
		
   	    context.moveTo(newPoints[0].x, newPoints[0].y);
    		        
        for(var i:int=1; i<newPoints.length+1; i++)
        {
        	context.lineTo(
                    	newPoints[i%newPoints.length].x, 
                    	newPoints[i%newPoints.length].y,
                    	i%newPoints.length==0?true:false );
        }
    }	
    
    /**
     * @private 
     */
    private static function _rect(	g:Graphics,
    								left:Number, top:Number,
    								width:Number, height:Number):void
    {
    	_polygon(	g,
					[	[left,top], 
						[left+width, top], 
						[left+width, top+height], 
						[left, top+height] ]);
    }
    
    /**
     * @private 
     */
    private static function _roundPolygon(	g:Graphics,
	    									points:Array,
        									radius:Number=20):void
    {        	
    	var context:DrawContext = getGraphicsContext(g);
    	var pArr:Array = GraphicUtils.processPointArray(points);
    	var pBArr:Array = [];
    	var i:int;
    	var cPDistance:Number = radius*Math.SQRT2;
    	var inside:String;
    	var obj:Object;
    	
    	if(pArr.length<3)
    		return;

    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    		obj = processPoints(pArr, context.stroke.weight/2);
    	else
    		obj = processPoints(pArr);    	

   		pArr = obj.points;
   		inside = obj.inside;  
    	
    	// calculates arc points
        var len:int = pArr.length;
        pBArr = new Array(len);
        for(i=0; i<len; i++)
        {
        	var ls:LineSegment = new LineSegment(pArr[i%len], pArr[(i+1)%len]);
    		var side:String = ls.pointSide(pArr[(i+2)%len]);
			
			if(side)
			{
				var curCPDistance:Number = cPDistance;
				var curRadius:Number = radius;

    			var line1:LineSegment = new LineSegment(pArr[i%len], pArr[(i+1)%len]);
    			var line2:LineSegment = new LineSegment(pArr[(i+1)%len], pArr[(i+2)%len]);        		

				// get new radius for 'InsideFrame' style
		    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    			{
        			var _line11:LineSegment = line1.shift(radius, side);
	    			var _line22:LineSegment = line2.shift(radius, side);

        			var _p:Point = _line11.lineIntersection(_line22);

        			var _matrix:Matrix = line1.toVerticalMatrix();        		
        			var _p1:Point = _matrix.transformPoint(_p);
        			_p1.x = 0;	        		
        			_matrix.invert();   		   		    	    		        			
        			_p1 = _matrix.transformPoint(_p1);
        			
        			var distance1:Number = Point.distance(line1.p2, _p1);
        			var distance2:Number = context.stroke.weight/2;

        			_line11 = line1.shift(distance2, side);
	    			_line22 = line2.shift(distance2, side);

        			_p = _line11.lineIntersection(_line22);
		    		var _side:String = ls.pointSide(_p);        			
					
        			var distance3:Number = Point.distance(line1.p2, _p);
        			var distance4:Number = Math.sqrt(distance3*distance3 - distance2*distance2);
        			var distance5:Number = distance1 - distance4;
        			var distance6:Number = distance1 + distance4;
        			
        			if(_side!=inside)
        				curRadius = distance6 * radius / distance1;
        			else	        		
        				curRadius = distance5 * radius / distance1;
	        		
	        		curCPDistance = curRadius*Math.SQRT2;
       			}			        		
        		
        		var line11:LineSegment = line1.shift(curRadius, side);
	    		var line22:LineSegment = line2.shift(curRadius, side);
	    		
        		// center of the corner arc
        		var p:Point = line11.lineIntersection(line22);
        		
        		// get 1st anchor point
        		var matrix:Matrix = line1.toVerticalMatrix();
        		
        		var p1:Point = matrix.transformPoint(p);
        		p1.x = 0;	        		
        		matrix.invert();   		   		    	    		        			
        		p1 = matrix.transformPoint(p1);        			        		

        		// get 2nd anchor point
    			line2 = new LineSegment(pArr[(i+2)%len], pArr[(i+1)%len]);
        		matrix = line2.toVerticalMatrix();

        		var p2:Point = matrix.transformPoint(p);
        		p2.x = 0;	        		
        		matrix.invert();   		   		    	    		        			
        		p2 = matrix.transformPoint(p2);
        		
        		// get control point        		
        		if(Point.distance(p, pArr[(i+1)%len])>curCPDistance)
        		{
        			var line:LineSegment = new LineSegment(p, pArr[(i+1)%len]);
        			matrix = line.toVerticalMatrix();    
        			matrix.invert();
        		
        			var pc:Point = matrix.transformPoint(new Point(0, curCPDistance));
        		}
        		else	
        			pc = pArr[(i+1)%len];
        		
        		// fill arc points array
				pBArr[(i+1)%len] = [p1,pc,p2];	        		        			        		
			}
			else
			{
				pBArr[(i+1)%len] = null;
			}    				
        }
        
        do
        {
	        var changed:Boolean = false;
        	for(i=0; i<len; i++)
        	{
	        	if(pBArr[i%len] == null && pBArr[(i+1)%len] == null)
	        		continue;	        		
        			        	
    	    	if(Point.distance(pArr[i%len], pArr[(i+1)%len])+0.01 < 
        			(pBArr[i%len] ? Point.distance(pArr[i%len], pBArr[i%len][2]) : 0) + 
        			(pBArr[i%len]&&pBArr[(i+1)%len] ? Point.distance(pBArr[i%len][2], pBArr[(i+1)%len][0]) : 0) + 
	        		(pBArr[(i+1)%len] ? Point.distance(pArr[(i+1)%len], pBArr[(i+1)%len][0]) : 0) )
	        	{
		        	if(pBArr[i%len] && pBArr[(i+1)%len])
		        	{
		        		if(	Point.distance(pArr[i%len], pBArr[i%len][2]) > 
			       			Point.distance(pArr[(i+1)%len], pBArr[(i+1)%len][0]) )
	    	    			pBArr[i%len] = null;
		        		else
	        				pBArr[(i+1)%len] = null;
		        	}
	        		else
	        		{
    	    			pBArr[i%len] = null;
        				pBArr[(i+1)%len] = null;
        			}
        			changed = true;
	        	}
	        }
        } while(changed)
        	
        if(pBArr[0])
        	context.moveTo( pBArr[0][2].x, pBArr[0][2].y ); 
        else
        	context.moveTo( pArr[0].x, pArr[0].y ); 
         
        for(i=1; i<len+1; i++)
        {	        
        	if(pBArr[i%len])
        	{
        		context.lineTo(
	                    	pBArr[i%len][0].x, 
    	                	pBArr[i%len][0].y);

        		context.quadraticBezierTo(
        				pBArr[i%len][1].x, 
                    	pBArr[i%len][1].y,
                    	pBArr[i%len][2].x, 
    	                pBArr[i%len][2].y);
                    	  
        	}
        	else
        	{	        	
        		context.lineTo(	
                    		pArr[i%len].x, 
                    		pArr[i%len].y,
                    		i%len==0?true:false);
        	}
        }
        
    }	

    /**
     * @private 
     */
    private static function _roundRect(	g:Graphics,
    									left:Number, top:Number,
    									width:Number, height:Number,
    									radius:Number=20):void
    {
    	_roundPolygon(	g,
							[	[left,top], 
								[left+width, top], 
								[left+width, top+height], 
								[left, top+height] ],
							radius );
    }
	
    /**
     * @private 
     */
	private static function _arc(	g:Graphics,
   									x:Number, y:Number, 
									startAngle:Number, endAngle:Number,
									radiusH:Number, radiusV:Number=0.0,
									angle:Number=0.0,
									closed:Boolean=true):void
    {
    	if(radiusH<1 && radiusV<1)
    		return;
    		
    	if(radiusH<1)
    		radiusH = radiusV;
    	else if(radiusV<1)
    		radiusV = radiusH;
    		
		var context:DrawContext = getGraphicsContext(g); 
    	
    	var shift:Number = 0;
    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    		shift = context.stroke.weight/2;
    		
    	var args:Object = processArcPie(	shift,
											radiusH, radiusV,
											angle,        								 
											startAngle, endAngle,
											closed);
		if(!args.isDrawing)
			return;
		   	
    	context.arc(
				x, y,
				args.radiusH, args.radiusV,
				angle,
				args.startAngle, args.endAngle,
				false,
				closed);
    }
    
    /**
     * @private 
     */
	private static function _pie(	g:Graphics,
   									x:Number, y:Number, 
									startAngle:Number, endAngle:Number,
									radiusH:Number, radiusV:Number=0.0,
									angle:Number=0.0):void
    {
    	if(radiusH<1 && radiusV<1)
    		return;
    		
    	if(radiusH<1)
    		radiusH = radiusV;
    	else if(radiusV<1)
    		radiusV = radiusH;
    		
		var context:DrawContext = getGraphicsContext(g); 

    	var shift:Number = 0;
    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    		shift = context.stroke.weight/2;
    	
    	var args:Object = processArcPie(	shift,
											radiusH, radiusV,   
											angle,     								 
											startAngle, endAngle,
											false, true);

		if(!args.isDrawing)
			return;
											
    	context.moveTo(x+args.center.x, y-args.center.y);
    	
    	context.arc(
				x, y,
				args.radiusH, args.radiusV,
				angle,
				args.startAngle, args.endAngle,				
				true,
				false);
		
		context.lineTo(x+args.center.x, y-args.center.y, true);
    }
            
    /**
     * @private 
     */
	private static function _circle(	g:Graphics,
   										x:Number,y:Number,
   										radius:Number):void
    {
		var context:DrawContext = getGraphicsContext(g); 
    	var newRadius:Number = radius;
    	
    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    	{
			newRadius -= context.stroke.weight/2;        		
    	}
    	
    	context.arc(
				x, y,
				newRadius,newRadius,
				0,
				0, 360, 
				false,
				true);
    }
    
    /**
     * @private 
     */
    private static function _ellipse(	g:Graphics,
    									x:Number,y:Number,
    									width:Number,height:Number,
    									angle:Number=0.0):void
    {
		var context:DrawContext = getGraphicsContext(g); 
    	var newRadiusH:Number = width/2;
    	var newRadiusV:Number = height/2;
    	
    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    	{
			newRadiusH -= context.stroke.weight/2;        		
			newRadiusV -= context.stroke.weight/2;        		
    	}

    	context.arc(	
				x, y,
				newRadiusH,newRadiusV,
				angle,
				0, 360, 
				false,
				true);
    }	 
	
    /**
     * @private 
     */
	private static function  _catmullRom( g:Graphics, points:Array ):void
	{
		var context:DrawContext = getGraphicsContext(g); 
    	var newPoints:Array = GraphicUtils.processPointArray(points);  
		
    	if(newPoints.length<2)
    		return;
    	
   		context.catmullRom(newPoints, false);
    }

    /**
     * @private 
     */
	private static function  _polyBezier( g:Graphics, points:Array ):void
    {
		var context:DrawContext = getGraphicsContext(g); 
    	var newPoints:Array = GraphicUtils.processPointArray(points);  
		
    	if(newPoints.length<4)
    		return;
    	
    	for(var i:int=0; i<=newPoints.length-4; i++)
    	{
    		context.cubicBezier(
						 	newPoints[i].x, newPoints[i].y,							 	
						 	newPoints[i+1].x, newPoints[i+1].y,							 	
						 	newPoints[i+2].x, newPoints[i+2].y,							 	
						 	newPoints[i+3].x, newPoints[i+3].y,
						 	i==0?false:true);
    	}
    }
       								
    /**
     * @private 
     */
    private static function _closedBezier( g:Graphics, points:Array ):void
    {        	
		var context:DrawContext = getGraphicsContext(g); 
    	var newPoints:Array = GraphicUtils.processPointArray(points);
    	
    	if(newPoints.length<3)
    		return;

    	if(context.stroke.patternName==StrokePatternStyle.INSIDEFRAME.name)
    		newPoints = processPoints(newPoints, context.stroke.weight/2).points;
    	else
    		newPoints = processPoints(newPoints).points;

		var len:int = newPoints.length;
    	for(var i:int=0; i<len; i++)
    	{
    		context.cubicBezier( 	
						 	newPoints[i%len].x, newPoints[i%len].y,							 	
						 	newPoints[(i+1)%len].x, newPoints[(i+1)%len].y,							 	
						 	newPoints[(i+2)%len].x, newPoints[(i+2)%len].y,							 	
						 	newPoints[(i+3)%len].x, newPoints[(i+3)%len].y,
						 	i==0?false:true);
    	}
    }
    
}
}