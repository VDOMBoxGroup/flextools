package DiagramAPI.com.baseClasses
{
import DiagramAPI.com.ConnectorEvent;

import DrawingAPI.com.Draw;
import DrawingAPI.com.PStroke;

import ExtendedAPI.com.utils.GeomUtils;

import GeomLib._2D.LineSegment;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.ArrayCollection;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

//--------------------------------------
//  Events
//--------------------------------------	

//--------------------------------------
//  Styles
//--------------------------------------

[Style(name="color", type="uint", format="Color", inherit="yes")]
[Style(name="alpha", type="Number", format="Length", inherit="yes")]
[Style(name="strokeWidth", type="Number", format="Length", inherit="no")]

[Style(name="endPointSize", type="Array", arrayType="uint", format="Length", inherit="no")]
[Style(name="endPointIcon1", type="Class", inherit="no")]
[Style(name="endPointIcon2", type="Class", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

//[IconFile("BaseConnector.png")]

//[ExcludeClass]

public class BaseConnector extends UIComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------		
    
    /**
    * Defines area offset around an connector where it can receive focus
    */
    private static const SELECT_AREA_SIZE:int = 5;

    public static const TYPE_STRAIGHT:String = "straight";
    public static const TYPE_CURVED:String = "curved";
    public static const TYPE_RIGHT_ANGLE:String = "rightAngle";
    
    // Define a static variable.
    private static var _classConstructed:Boolean = classConstruct();
    
    public static function get classConstructed():Boolean 
    {
    	return _classConstructed;
    }
        
    // Define a static method.
    private static function classConstruct():Boolean 
    {
    	var className:String = "BaseConnector";
        
        if (!StyleManager.getStyleDeclaration(className))
        {
            // If there is no CSS definition for Connector, 
            // then create one and set the default value.
            var newStyleDeclaration:CSSStyleDeclaration;
            
            if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("UIComponent")))
            {
                newStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("themeColor", "haloBlue");
            }

            newStyleDeclaration.setStyle("color", 0x000000);
            newStyleDeclaration.setStyle("alpha", 1.0);
            newStyleDeclaration.setStyle("strokeWidth", 1);
		
            StyleManager.setStyleDeclaration(className, newStyleDeclaration, true);
        }
    	
        return true;
    }        	  

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Constructor.
     */
	public function BaseConnector()
	{
		super();
		styleName = this.className;	
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
	protected var _sprite:Sprite;
	protected var _sprite1:Sprite;
	protected var _sprite2:Sprite;
	
    public var _anchorPoints:ArrayCollection = new ArrayCollection(); 

    public var _controlPoints:ArrayCollection = new ArrayCollection(); 
    
    protected var _controlPoints2:ArrayCollection = new ArrayCollection();
    
    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  type
    //----------------------------------
    
    private var _type:String = TYPE_STRAIGHT;
	private var _typeChanged:Boolean;
	
    [Bindable("typeChanged")]
    [Inspectable(category="General", enumeration="straight,rightAngle,curved", defaultValue="straight")]

    public function get type():String
    {
        return _type;
    }	
    public function set type(value:String):void
    {
		if(_type!=value)
		{
        	_type = value;
        	_typeChanged = true;
        	
        	invalidateProperties();
        	
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.TYPE_CHANGED));
  		}
    }
    
    //----------------------------------
    //  endPointShape1
    //----------------------------------
    
    private var _endPointPoly1:Array = [];
    private var _endPointBitmap1:Bitmap;
    private var _endPointShape1:Object;
	private var _endPointShape1Changed:Boolean;
	
    [Bindable("endPointShape1Changed")]
    [Inspectable(category="General")]

    public function get endPointShape1():Object
    {
        return _endPointShape1;
    }	
    public function set endPointShape1(value:Object):void
    {
		if(_endPointShape1!=value)
		{
        	_endPointShape1 = value;
        	_endPointShape1Changed = true;
        
        	invalidateProperties();
  		}
    }
        
    //----------------------------------
    //  endPointShape2
    //----------------------------------
    
    private var _endPointPoly2:Array = [];
    private var _endPointBitmap2:Bitmap;
    private var _endPointShape2:Object;
	private var _endPointShape2Changed:Boolean;
	
    [Bindable("endPointShape2Changed")]
    [Inspectable(category="General")]

    public function get endPointShape2():Object
    {
        return _endPointShape2;
    }	
    public function set endPointShape2(value:Object):void
    {
		if(_endPointShape2!=value)
		{
        	_endPointShape2 = value;
        	_endPointShape2Changed = true;
        
        	invalidateProperties();
  		}
    }

	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------	
	
    override public function styleChanged(styleProp:String):void 
    {
        super.styleChanged(styleProp);
    	
    	if (styleProp=="strokeWidth" || 
    		styleProp=="endPointSize") 
    	{
    		getEndPointsBitmaps();
        	invalidateSize();
    	}
    	
	   	if( styleProp=="endPointIcon1" )
    	{
    		getEndPointsBitmaps(1, 'style');
        	invalidateSize();		
    	}
    	
	   	if( styleProp=="endPointIcon2" )
    	{
    		getEndPointsBitmaps(2, 'style');
        	invalidateSize();		
    	}
    	    	
        invalidateDisplayList();
	}
	
	/**
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if(!_sprite)
        {
        	_sprite = new Sprite();
        	addChild(_sprite);	
        }        
        if(!_sprite1)
        {
        	_sprite1 = new Sprite();
        	_sprite.addChild(_sprite1);	

        	_endPointBitmap1 = new Bitmap();
        	_endPointBitmap1.smoothing = true;
        	_sprite1.addChild(_endPointBitmap1);	
        } 
        if(!_sprite2)
        {
        	_sprite2 = new Sprite();
        	_sprite.addChild(_sprite2);	

        	_endPointBitmap2 = new Bitmap();
        	_endPointBitmap2.smoothing = true;
        	_sprite2.addChild(_endPointBitmap2);	
        } 

        if(_anchorPoints.length==0) 
        {
	    	_anchorPoints.addItem(new InteractivePoint(0, 0));
			_anchorPoints.addItem(new InteractivePoint(100, 100));
			
			processPoints(true);		
    	}
    }

    override protected function commitProperties():void
    {
        super.commitProperties();

    	if(!isNaN(percentWidth) || !isNaN(explicitWidth))
    	{
    		percentWidth = explicitWidth = NaN;
            invalidateSize();
    	}
    	
    	if(!isNaN(percentHeight) || !isNaN(explicitHeight))
    	{
	    	percentHeight = explicitHeight = NaN;
            invalidateSize();
	    }
        	        
        if (_typeChanged)
        {
        	_typeChanged = false;   
        	
        	processPoints(true);     	
        	
        	invalidateSize();
          	invalidateDisplayList();
        }
        
        if(_endPointShape1Changed)
        {
        	_endPointShape1Changed = false;
        	
    		getEndPointsBitmaps(1, 'property');

        	invalidateSize();
          	invalidateDisplayList();
        }
        
        if(_endPointShape2Changed)
        {
        	_endPointShape2Changed = false;
        	
    		getEndPointsBitmaps(2, 'property');

        	invalidateSize();
          	invalidateDisplayList();
        }
    }
    
	override protected function measure():void 
	{
        super.measure();                   

		var offset:Number = getStyle("strokeWidth")/2;
        
        if(_anchorPoints.length) {
        	offset -=
        		InteractivePoint(_anchorPoints[0]).width/2;	            
        }
        		
		var poly1:Array = proccessEndPoint(1);
		var poly2:Array = proccessEndPoint(2);
		
		var rectEndP1:Rectangle = GeomUtils.getObjectsRect(poly1);
		var rectEndP2:Rectangle = GeomUtils.getObjectsRect(poly2);
		
		var rect:Rectangle = GeomUtils.getObjectsRect(
					_anchorPoints, _controlPoints, _controlPoints2,
					rectEndP1, rectEndP2 );
					
		rect.inflate(offset, offset);
		
		var dX:Number = rect.x;
		var dY:Number = rect.y;		

		if(dX || dY)
		{
			GeomUtils.offsetObjects(
				-dX, -dY, 
				_anchorPoints, _controlPoints, _controlPoints2,
				_sprite1, _sprite2);

			move( 	this.x + dX,
					this.y + dY );
		}
		
   		measuredMinWidth = measuredWidth = rect.width;
   		measuredMinHeight = measuredHeight = rect.height;
   		
   		invalidateDisplayList();
    }  	    		
   
	// Override updateDisplayList() to update the component 
	override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		graphics.clear();
		_sprite.graphics.clear();
		
		if(!_anchorPoints || _anchorPoints.length<2)
			return;
		
		var g:Graphics = _sprite.graphics;		

		var color:Number = getStyle("color");
		
		// Define intercative area
		var stroke:PStroke = new PStroke(0x000000, SELECT_AREA_SIZE, null, 0.0); 
		Draw.applyStroke(g, stroke);
		drawConnector(g, color);
		
		// Draw connector line
		stroke = new PStroke(color, getStyle("strokeWidth"), null, getStyle("alpha"), 
			false, "normal", CapsStyle.ROUND, JointStyle.MITER);	
		Draw.applyStroke(g, stroke);
		drawConnector(g, color);
		
		// Draw end points
		stroke = new PStroke(color, 0, null, getStyle("alpha"), 
			false, "normal", CapsStyle.SQUARE, JointStyle.MITER);	
		drawEndPoints(g, stroke);

		// draw border rect
		//graphics.lineStyle(1, 0x00ffff, 1);
		//graphics.drawRect(0, 0, unscaledWidth-1, unscaledHeight-1);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	protected function drawConnector(g:Graphics, color:Number):void
	{			
		Draw.moveTo(g, InteractivePoint(_anchorPoints[0])._context.centerX, 
						InteractivePoint(_anchorPoints[0])._context.centerY);
		switch(type)
		{
			case TYPE_RIGHT_ANGLE:
				for (var i:int=0; i<_controlPoints.length; i++)
					Draw.lineTo(g,	InteractivePoint(_controlPoints[i])._context.centerX, 
									InteractivePoint(_controlPoints[i])._context.centerY);
				
				Draw.lineTo(g,	InteractivePoint(_anchorPoints[1])._context.centerX, 
								InteractivePoint(_anchorPoints[1])._context.centerY);
				break;

			case TYPE_CURVED:
				var arr:Array = [];
				
				arr.push(new Point(_anchorPoints[0]._context.centerX, _anchorPoints[0]._context.centerY));
				
				for each (var p:InteractivePoint in _controlPoints)
					arr.push(new Point(p._context.centerX, p._context.centerY));
				
				arr.push(new Point(_anchorPoints[1]._context.centerX, _anchorPoints[1]._context.centerY));
				
				Draw.catmullRom(g, arr);
				break;

			default:
				Draw.lineTo(g,	InteractivePoint(_anchorPoints[1])._context.centerX, 
								InteractivePoint(_anchorPoints[1])._context.centerY);
		}
	}    
	
	protected function drawEndPoints(g:Graphics, stroke:PStroke):void
	{
		var arr:Array = []; 
		
		if(_endPointPoly1.length>0) {
			arr.push( [_endPointPoly1, _sprite1.graphics] );
		}
		if(_endPointPoly2.length>0) {
			arr.push( [_endPointPoly2, _sprite2.graphics] );
		}
		
		for each(var polyGr:Array in arr)
		{
			var poly:Array = polyGr[0];
			var graphics:Graphics = polyGr[1];
			graphics.clear();
			Draw.applyStroke(graphics, stroke);
			
			if(poly.length>0)
				Draw.moveTo(graphics, poly[poly.length-1].x, poly[poly.length-1].y);
			
			graphics.beginFill(stroke.color, stroke.alpha);
			for (var i:int=0; i<poly.length; i++)
				Draw.lineTo(graphics, poly[i].x, poly[i].y);
			graphics.endFill();
		}		
	}
	
	protected function processPoints(rebuild:Boolean=false):void
	{
		var p:InteractivePoint;
		var p1:InteractivePoint;
		var p2:InteractivePoint;
		
		if(rebuild)
		{
			for each (var points:ArrayCollection in [_controlPoints, _controlPoints2])
				for each (var obj:UIComponent in points) {
					if(obj.parent)
						obj.parent.removeChild(obj);
				}
			
			_controlPoints.removeAll();
			_controlPoints2.removeAll();			
			
			switch(type)
			{	
				case TYPE_RIGHT_ANGLE:
					// add control point
					p1 = _anchorPoints[0];
					p2 = _anchorPoints[1];
					p = new InteractivePoint(	Math.max(p1._context.centerX, p2._context.centerX), 
												Math.min(p1._context.centerY, p2._context.centerY));
					_controlPoints.addItem(p);
					
					// add additional points
					p = new InteractivePoint();
					_controlPoints2.addItem(p);
					
					p = new InteractivePoint();
					_controlPoints2.addItem(p);
					break;
					
				case TYPE_CURVED:
					// add control point
					p1 = _anchorPoints[0];
					p2 = _anchorPoints[1];
					p = new InteractivePoint(	Math.max(p1._context.centerX, p2._context.centerX), 
												Math.min(p1._context.centerY, p2._context.centerY));
					_controlPoints.addItem(p);
					
					// add additional points
					p = new InteractivePoint();
					_controlPoints2.addItem(p);
					
					p = new InteractivePoint();
					_controlPoints2.addItem(p);
					break;
					
				default:
					// add additional points
					p = new InteractivePoint();
					_controlPoints2.addItem(p);
					break;
			}
		}

		switch(this.type)
		{	
			case TYPE_RIGHT_ANGLE:
				for(var i:int=0; i<_controlPoints2.length; i++) {
					p1 = i==0 ? _anchorPoints[0] : _controlPoints[i-1];
					p2 = i==_controlPoints2.length-1 ? _anchorPoints[1] : _controlPoints[i];
					p = _controlPoints2[i];				
					p._context.center = 
						Point.interpolate(p1._context.center, p2._context.center, 0.5);										
				}
				break;
			case TYPE_CURVED:			
				break;
			default:
				p1 = _anchorPoints[0];
				p2 = _anchorPoints[1];
				p = _controlPoints2[0];				
				p._context.center = Point.interpolate(p1._context.center, p2._context.center, 0.5);
				break;
		}
	}	
	
	protected function getIcon(styleName:String):IFlexDisplayObject
	{
		var iconClass:Class = Class(getStyle(styleName));	
        var icon:IFlexDisplayObject;
        
        if(iconClass)
        	icon = IFlexDisplayObject(new iconClass());
        
        if(!(icon is DisplayObject))        
        	icon = null;
        
        return icon;
	} 
	
	protected function getEndPointBitmapPoly(num:int, source:String=null):BitmapData
	{
		if(num!=1 && num!=2)
			return null;
		
		var endPointShape:Object = num==1 ? _endPointShape1 : _endPointShape2;  
		var poly:Array = num==1 ? _endPointPoly1 : _endPointPoly2;
		var bitmap:Bitmap = num==1 ? _endPointBitmap1 : _endPointBitmap2;  
		
		var bd:BitmapData;
		var endPointSize:Array = getStyle("endPointSize");

		var w:Number; 
		var h:Number;
		
		if(endPointSize && endPointSize.length>0)
		{
			w = endPointSize[0];
			h = endPointSize[0];
			
			if(endPointSize.length>1)
				h = endPointSize[1];
		}

		if(!source)
		{
			bd = bitmap.bitmapData;
		}
		
		if(String(endPointShape)=="arrow")
		{
			w = w>0 ? w : 7;	
			h = h>0 ? h : 8;
				
			poly = [];
			poly.push(
				new Point(0,0),
				new Point(w/2,h),
				new Point(-w/2,h)
			);
		}
		
		if(!bd && source == 'style')
		{
			var icon:IFlexDisplayObject = getIcon("endPointIcon"+num);
			if(icon) {
				w = w>0 ? w : icon.width;
				h = h>0 ? h : icon.height;									 
				bd = new BitmapData(w, h, true, 0x00000000);
				bd.draw(icon);
				
				poly = [];
			} 
		}		
		
		if(!bd && endPointShape is BitmapData)
		{
			bd = endPointShape as BitmapData;
			
			if(bd)
				poly = [];
		}
		
		if(num==1)
			_endPointPoly1 = poly;
		else
			_endPointPoly2 = poly;

		return bd;
	}
	
	protected function getEndPointsBitmaps(num:int=0, source:String=null):void
	{
		var arr:Array = [];

		if(num==1 || num==0) {
			arr.push([1, _endPointBitmap1]);
		}
		if(num==2 || num==0) {
			arr.push([2, _endPointBitmap2]);
		}

		for each (var obj:Array in arr)
		{
			Bitmap(obj[1]).bitmapData = getEndPointBitmapPoly(obj[0], source);
			if(Bitmap(obj[1]).bitmapData)
			{
				Bitmap(obj[1]).width = Bitmap(obj[1]).bitmapData.width;
				Bitmap(obj[1]).height = Bitmap(obj[1]).bitmapData.height;
				Bitmap(obj[1]).x = -Bitmap(obj[1]).width/2;
			}
		}			
	}
	
	protected function proccessEndPoint(num:int):Array
	{
		var shape:Object = num==1 ? _endPointShape1 : _endPointShape2;  
		var poly:Array = num==1 ? _endPointPoly1 : _endPointPoly2;  
		var bitmap:Bitmap = num==1 ? _endPointBitmap1 : _endPointBitmap2;  
		var matrix:Matrix = new Matrix();
		var arr:Array = [];
		matrix.identity();
		
		var aP1:Point = InteractivePoint(_anchorPoints[0])._context.center; 
		var aP2:Point = InteractivePoint(_anchorPoints[1])._context.center;
		var cP1:Point; 
		var cP2:Point;
		
		arr = [aP1]; 
		
		if(bitmap)
		{
			bitmap.parent.width = 0;
			bitmap.parent.height = 0;
			bitmap.parent.transform.matrix = matrix;			
			
			if(_controlPoints2.length>0)
			{
				cP1 = InteractivePoint(_controlPoints2[0])._context.center;
				cP2 = InteractivePoint(_controlPoints2[_controlPoints2.length-1])._context.center;
			}
						
			var p1:Point;
			var p2:Point;
			
			p1 = num==1 ? aP1 : aP2;
				
			if(cP1 || cP2)
				p2 = num==1 ? cP1 : cP2;
			else
				p2 = num==1 ? aP2 : aP1;

			if(bitmap.bitmapData || poly.length>0)
			{
				var line:LineSegment = new LineSegment(p1, p2);
								
				matrix = line.toVerticalMatrix();
				matrix.invert();
				
				bitmap.parent.transform.matrix = matrix;				
				
				arr = [];
				
				if(poly.length==0) 
				{
					poly = [];
					poly.push(
						new Point(-bitmap.bitmapData.width/2, 0),
						new Point(bitmap.bitmapData.width/2, 0),
						new Point(-bitmap.bitmapData.width/2, bitmap.bitmapData.height),
						new Point(bitmap.bitmapData.width/2, bitmap.bitmapData.height)
						);		
				}

				for (var i:int=0; i<poly.length; i++) {
					arr.push( matrix.transformPoint(poly[i]) );
				}
			}			
			else
			{
				bitmap.parent.x = p1.x;
				bitmap.parent.y = p1.y;
			}
		}
		return arr;
	}

	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

}
}