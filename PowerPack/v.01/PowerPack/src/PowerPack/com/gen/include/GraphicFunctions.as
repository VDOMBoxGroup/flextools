// ActionScript file
import DrawingAPI.com.Draw;
import DrawingAPI.com.PStroke;

import PowerPack.com.gen.parse.ListParser;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.BitmapFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * function section
 */
public function _drawLine( pic:Bitmap, 
					x1:int, y1:int, x2:int, y2:int,  
					pen:String, alpha:int ):Object
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	var shape:Shape = new Shape();
	var stroke:PStroke;
	var _fill:*;	
	
	stroke = ListParser.processSubFunc(pen, [context, GraphContext(contextStack[contextStack.length-1]).context]);	
	if(!(stroke is PStroke))
		stroke = new PStroke();
	
	Draw.applyStroke(shape.graphics, stroke);
	
	Draw.moveTo(shape.graphics, x1, y1);
	Draw.lineTo(shape.graphics, x2, y2);
	
	bd2.draw( shape );

	var ct:ColorTransform = new ColorTransform();
	ct.alphaOffset = -255 + alpha/100*255;	
	bd2.colorTransform(bd2.rect, ct);

	bd1.copyPixels(	bd2, bd2.rect, new Point(0,0), null, null, true);

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);	
}

/**
 * function section
 */
private function __drawFigure( pic:Bitmap, method:Function, params:Array,
					pen:String, fill:String, alpha:int ):Object
{
	var _params:Array;
	var rect:Rectangle;
	
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	var alphaBD:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	var figureBD:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );

	var shape:Shape = new Shape();
	var aShape:Shape = new Shape();
	var stroke:PStroke;
	var _fill:*;	

	bd1.draw( pic );

	aShape.graphics.beginFill(0x000000);	
	
	_params = params.concat();
	_params.unshift(aShape.graphics);
	method.apply(null, _params);
	
	aShape.graphics.endFill();
	alphaBD.draw( aShape );
	
	rect = alphaBD.getColorBoundsRect(0xff000000, 0x00000000, false);
	
	figureBD.copyPixels(bd1, bd1.rect, new Point(0,0), alphaBD, null, true);	
	
	if(fill)
		_fill = __processFillList(fill, shape.graphics, rect);
	
	if(_fill is BitmapFilter)
	{
		figureBD.applyFilter(figureBD, figureBD.rect, new Point(0,0), _fill);
		bd1.copyPixels(figureBD, figureBD.rect, new Point(0,0), null, null, true);		
	}

	stroke = ListParser.processSubFunc(pen, [context, GraphContext(contextStack[contextStack.length-1]).context]);	
	if(!(stroke is PStroke))
		stroke = new PStroke();
	
	Draw.applyStroke(shape.graphics, stroke);	

	_params = [];
	_params = params.concat();
	_params.unshift(shape.graphics);
	method.apply(null, _params);

	if(_fill && !(_fill is BitmapFilter))
		shape.graphics.endFill();
	
	bd2.draw( shape );

	var ct:ColorTransform = new ColorTransform();
	ct.alphaOffset = -255 + alpha/100*255;	
	bd2.colorTransform(bd2.rect, ct);		

	bd1.copyPixels(	bd2, bd2.rect, new Point(0,0), null, null, true);

	return new Bitmap(bd1);	
}

/**
 * function section
 */
public function _drawAngleArc( pic:Bitmap, 
					x:int, y:int, radius:uint, 
					startAngle:Number, endAngle:Number,
					pen:String, fill:String, alpha:int ):Object
{
	var ret:* = __drawFigure( pic, Draw.pie, 
					[x, y, startAngle, endAngle, radius, radius, 0],
					pen, fill, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _drawEllipse( pic:Bitmap, 
					x1:int, y1:int, x2:int, y2:int,  
					pen:String, fill:String, alpha:int ):Object
{
	var ret:* = __drawFigure( pic, Draw.ellipse, 
					[x1, y1, x2-x1, y2-y1, 0],
					pen, fill, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _drawRect( pic:Bitmap, 
					x1:int, y1:int, x2:int, y2:int,  
					pen:String, fill:String, alpha:int ):Object
{
	var ret:* = __drawFigure( pic, Draw.rect, 
					[x1, y1, x2-x1, y2-y1],
					pen, fill, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _drawRoundRect( pic:Bitmap, 
					x1:int, y1:int, x2:int, y2:int, radius:uint,
					pen:String, fill:String, alpha:int ):Object
{
	var ret:* = __drawFigure( pic, Draw.roundRect, 
					[x1, y1, x2-x1, y2-y1, radius],
					pen, fill, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _drawBezier( pic:Bitmap, 
					points:String,  
					pen:String, alpha:int ):Object
{
	var _points:Array = ListParser.processPoints(points, [context, GraphContext(contextStack[contextStack.length-1]).context]);
	var ret:* = __drawFigure( pic, Draw.polyBezier, 
					[_points],
					pen, null, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _fillBezier( pic:Bitmap, 
					points:String,  
					pen:String, fill:String, alpha:int ):Object
{
	var _points:Array = ListParser.processPoints(points, [context, GraphContext(contextStack[contextStack.length-1]).context]);
	var ret:* = __drawFigure( pic, Draw.closedBezier, 
					[_points],
					pen, fill, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _drawPolygon( pic:Bitmap, 
					points:String,  
					pen:String, fill:String, alpha:int ):Object
{
	var _points:Array = ListParser.processPoints(points, [context, GraphContext(contextStack[contextStack.length-1]).context]);
	var ret:* = __drawFigure( pic, Draw.polygon, 
					[_points],
					pen, fill, alpha );

	Application.application.callLater(generate);
	
	return ret;	
}

/**
 * function section
 */
public function _writeText( pic:Bitmap, text:String,
					x:int, y:int, w:int, h:int,  
					font:String, alpha:int ):Object
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	var sprite:Sprite = new Sprite();
	var format:TextFormat;
	var tf:TextField;

	format = ListParser.processSubFunc(font, [context, GraphContext(contextStack[contextStack.length-1]).context]);
		
	if(!(format is TextFormat))
		format = new TextFormat();
	
	tf = new TextField();
	//tf.autoSize = TextFieldAutoSize.RIGHT;
	tf.background = false;
	tf.border = false;
	tf.selectable = false;
	tf.multiline = true;
	tf.wordWrap = true;
    tf.width = w;
    tf.height = h;    
    
    tf.defaultTextFormat = format;

    tf.text = text;
    
	sprite.addChild( tf );		
	
	bd2.draw( sprite );

	var ct:ColorTransform = new ColorTransform();
	ct.alphaOffset = -255 + alpha/100*255;	
	bd2.colorTransform(bd2.rect, ct);

	bd1.copyPixels(	bd2, bd2.rect, new Point(x,y), null, null, true);

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);	
}
