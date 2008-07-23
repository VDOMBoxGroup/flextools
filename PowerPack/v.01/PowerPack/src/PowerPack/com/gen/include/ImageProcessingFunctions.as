// ActionScript file
import ExtendedAPI.com.utils.FileUtils;
import ExtendedAPI.com.utils.GeomUtils;

import GraphicAPI.GraphicUtils;

import PowerPack.com.BasicError;
import PowerPack.com.gen.parse.ListParser;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.ConvolutionFilter;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

private function __processFillList(list:String, g:Graphics, rect:Rectangle):*
{
	var _fill:* = ListParser.processSubFunc(list, [context, GraphContext(contextStack[contextStack.length-1]).context]);
	var matrix:Matrix = new Matrix();
	matrix.translate(rect.x, rect.y);
	
	if(_fill is BitmapFilter) {
		//
	}
	else if(_fill is BitmapData) {
		g.beginBitmapFill(_fill, matrix);
	}
	else if(_fill is Bitmap) {
		g.beginBitmapFill(_fill.bitmapData, matrix);
	}
	else if(_fill && typeof(_fill) == 'number') {
		g.beginFill(_fill);
	}
	else if(_fill && typeof(_fill) == 'object' && 
		_fill.hasOwnProperty('name')) 
	{
		matrix = new Matrix();
		matrix.createGradientBox(	rect.width/(_fill.name=='gradientoneway'?1:2), 
									rect.height/(_fill.name=='gradientoneway'?1:2), 
									_fill.rotation, 0, 0);
		g.beginGradientFill( _fill.type, _fill.colors, _fill.alphas, _fill.ratios, matrix, _fill.spreadMethod);
	}
	
	return _fill;	
}

/**
 * function section
 */		 
public function _loadImage(filename:String):void
{
	if(!filename || !FileUtils.isValidPath(filename))
	{
		throw new BasicError("Not valid filename");
	}

	var file:File = new File();
	file.url = FileUtils.pathToUrl(filename);

	if(!file.exists)
	{
		throw new BasicError("File does not exists");
	}
	
	var fileStream:FileStream = new FileStream();
	var bytes:ByteArray = new ByteArray();
	fileStream.open(file, FileMode.READ);
	fileStream.readBytes(bytes, 0, fileStream.bytesAvailable);
	fileStream.close();
	
	var loader:Loader = new Loader();
	loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaded );
	loader.loadBytes( bytes );
	
	function onImageLoaded(event:Event):void {
		var content:DisplayObject = LoaderInfo( event.target ).content;
		var bitmapData:BitmapData = new BitmapData( content.width, content.height, true, 0x00000000 );
		bitmapData.draw( content );
		var bitmap:Bitmap = new Bitmap(bitmapData);
		
		parsedNode.string = bitmap;
		
		Application.application.callLater(generate);
	}
}


/**
 * createPicture function section
 */		

public function _createImage(width:int, height:int, bgColor:uint):Object
{
	if(bgColor<0x01000000)
		bgColor += 0xff000000;
	
	var bitmapData:BitmapData = new BitmapData( width, height, true, bgColor );
	var bitmap:Bitmap = new Bitmap(bitmapData);
	
	Application.application.callLater(generate);
	
	return bitmap;
}

/**
 * function section
 */
public function _getWidth(pic:Bitmap):int
{
	Application.application.callLater(generate);
	return pic.width;
}

/**
 * function section
 */		
public function _getHeight(pic:Bitmap):int
{
	Application.application.callLater(generate);
	return pic.height;
}

/**
 * function section
 */
public function _getPixel( pic:Bitmap, x:int, y:int ):uint 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	
	bd1.draw( pic );

	Application.application.callLater(generate);
	
	return bd1.getPixel(x, y);		
}

/**
 * function section
 */
public function _getPixel32( pic:Bitmap, x:int, y:int ):uint 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	
	bd1.draw( pic );

	Application.application.callLater(generate);
	
	return bd1.getPixel32(x, y);		
}

/**
 * function section
 */
public function _setPixel( pic:Bitmap, x:int, y:int, color:uint ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	
	bd1.draw( pic );	

	if(color>0xffffff)
		bd1.setPixel32(x,y,color);
	else
		bd1.setPixel(x,y,color);
	
	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _addImage(...args):Object
{
	if(args.length==5)
		args.unshift(args[0]);
	
	return __addImage.apply(this, args);
}

private function __addImage(pic1:Bitmap, pic2:Bitmap, x:int, y:int, alpha:int, alphaCol:int):Object
{
	var bd1:BitmapData = new BitmapData( pic1.width, pic1.height, true, 0x00ffffff );
	var bd2:BitmapData = new BitmapData( pic2.width, pic2.height, true, 0x00ffffff );
	
	bd1.draw( pic1 );	
	bd2.draw( pic2 );	

	var ct:ColorTransform = new ColorTransform();
	ct.alphaOffset = -255 + alpha/100*255;	
	bd2.colorTransform(bd2.rect, ct);		
	
	if(alphaCol>=0)
		bd2.threshold(bd2, bd2.rect, new Point(0,0), '==', alphaCol, 0x00000000, 0x00ffffff, true);	
	
	bd1.copyPixels(	bd2, bd2.rect, new Point(x,y), null, null, true);

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);
}

/**
 * function section
 */
public function _mergeImages( pic1:Bitmap, pic2:Bitmap, percent:uint ):Object 
{
	return __addImage(pic1, pic2, 0, 0, percent, -1);
}

/**
 * function section
 */
public function _brightness( pic:Bitmap, value:int ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	var matrix:Array = [	1,0,0,0,value,
							0,1,0,0,value,
		  					0,0,1,0,value,
		  					0,0,0,1,0 ];
            
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new ColorMatrixFilter(matrix));

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _contrast( pic:Bitmap, value:int ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	
	bd1.draw( pic );
	
	if (value < -100) value=-100;
	if (value >  100) value=100;

	var contrast:Number = (100.0+value)/100.0;
	contrast *= contrast;

	for (var i:int=0; i<pic.width; i++)
	{
		for (var j:int=0; j<pic.height; j++)
		{
			var argb:uint = bd1.getPixel32(i, j);			
			
			var r:Number = (argb & 0xff0000)>>16;
			var g:Number = (argb & 0x00ff00)>>8;
			var b:Number = (argb & 0x0000ff);
            
            var pixel:Number;            
            
            argb = argb>>24;
            
            for each ( var c:Number in [r,g,b] )
            {    
				pixel = c/255.0;
				pixel -= 0.5;
				pixel *= contrast;
				pixel += 0.5;
				pixel *= 255;
				if (pixel < 0) pixel = 0;
				if (pixel > 255) pixel = 255;
				
				argb = argb<<8;
				argb += int(pixel);
            }

			bd2.setPixel32(	i, j, argb );
		}
	}
	
	Application.application.callLater(generate);
	
	return new Bitmap(bd2);			
}

/**
 * function section
 */
public function _saturation( pic:Bitmap, value:int ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	
	bd1.draw( pic );
	
	for (var i:int=0; i<pic.width; i++)
	{
		for (var j:int=0; j<pic.height; j++)
		{
			var argb:uint = bd1.getPixel32(i,j);
			var hsv:Object = GraphicUtils.RGB2HSV(argb);
			
			if(hsv.s>0.0)
				hsv.s += value/100 * (value>0 ? hsv.s : hsv.s);
			
			if(hsv.s<0)
				hsv.s=0;
			else if(hsv.s>1)
				hsv.s=1;			
			
			argb = GraphicUtils.HSV2RGB(hsv.h, hsv.s, hsv.v) + (0xff000000 & argb);
				
			bd2.setPixel32( i, j, argb );
		}
	}
		
	Application.application.callLater(generate);
	
	return new Bitmap(bd2);		
}

/**
 * function section
 */
public function _createBlackWhite( pic:Bitmap ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0xffffffff );
	var bd3:BitmapData = new BitmapData( pic.width, pic.height, true, 0xffffffff );
	
	bd1.draw( pic );
	
	var matrix:Array = [	0.33,0.33,0.33,0,0,
							0.33,0.33,0.33,0,0,
		  					0.33,0.33,0.33,0,0,
		  					0,0,0,1,0 ];
            
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new ColorMatrixFilter(matrix));
		
	bd2.threshold(bd1, bd1.rect, new Point(0,0), '<', 0x7f000000, 0xffffffff, 0xff000000, true);	
	bd3.threshold(bd2, bd2.rect, new Point(0,0), '<', 0x007f0000, 0xff000000, 0x00ff0000, false);	
	
	Application.application.callLater(generate);
	
	return new Bitmap(bd3);		
}

/**
 * function section
 */
public function _createGrayScale( pic:Bitmap ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	var matrix:Array = [	0.33,0.33,0.33,0,0,
							0.33,0.33,0.33,0,0,
		  					0.33,0.33,0.33,0,0,
		  					0,0,0,1,0 ];
            
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new ColorMatrixFilter(matrix));
		
	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _createNegative( pic:Bitmap ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	
	bd1.draw( pic );
	
	var matrix:Array = [	-1,0,0,0,255,
							0,-1,0,0,255,
		  					0,0,-1,0,255,
		  					0,0,0,1,0 ];
            
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new ColorMatrixFilter(matrix));

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _cropImage( pic:Bitmap, x:int, y:int, w:int, h:int):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00000000 );
	var bd2:BitmapData = new BitmapData( w, h, true, 0x00000000 );
	
	bd1.draw( pic );
	
	bd2.copyPixels(bd1, new Rectangle(x,y,w,h), new Point(0,0)); 

	Application.application.callLater(generate);
	
	return new Bitmap(bd2);		
}

/**
 * function section
 */
public function _flipImage( pic:Bitmap, direction:*):Object
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	var bd2:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	var _direction:int = ListParser.processFlipDirection(direction);	
	
	for (var i:int=0; i<pic.width; i++)
	{
		for (var j:int=0; j<pic.height; j++)
		{
			bd2.setPixel32(	_direction!=1?pic.width-1-i:i, 
							_direction==1?pic.height-1-j:j, 
							bd1.getPixel32(i,j) );
		}
	}
	
	Application.application.callLater(generate);
	
	return new Bitmap(bd2);	
}

/**
 * function section
 */
public function _resizeImage( pic:Bitmap, w:int, h:int ):Object 
{
	var bd1:BitmapData = new BitmapData( w, h, true, 0x00000000 );
	
	var matrix:Matrix = new Matrix();
	matrix.scale( w/pic.width, h/pic.height );
	
	bd1.draw( pic, matrix );
	
	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _rotateImage( pic:Bitmap, angle:int, bgColor:uint ):Object 
{	
	var matrix:Matrix = new Matrix();
	matrix.rotate( angle / 360 * Math.PI * 2 );
	
	var rect:Rectangle = new Rectangle(0,0,pic.width,pic.height);
	var points:Array = [];
	
	points.push(matrix.transformPoint(rect.topLeft));
	points.push(matrix.transformPoint(rect.bottomRight));
	points.push(matrix.transformPoint(new Point(rect.right, rect.top)));
	points.push(matrix.transformPoint(new Point(rect.left, rect.bottom)));
	
	rect = GeomUtils.getObjectsRect(points);
	
	matrix.translate(-rect.left, -rect.top);
	
	if(bgColor<0)
		bgColor = 0x00000000;	
	else if(bgColor<0x01000000)
		bgColor += 0xff000000;
	
	var bd1:BitmapData = new BitmapData( rect.width, rect.height, true, bgColor );	

	bd1.draw( pic, matrix, null, null, null, true );
	
	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _blur( pic:Bitmap, value:int ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new BlurFilter(value, value));

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _sharpen( pic:Bitmap, value:int ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	// sharpen matrix
	var matrix:Array = [0, -1-value/4, 0,
                        -1-value/4, 13+value, -1-value/4,
                        0, -1-value/4, 0];

    var matrixX:Number = 3;
    var matrixY:Number = 3;
    var divisor:Number = 9;
    var bias:Number = 0;
    
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new ConvolutionFilter(matrixX, matrixY, matrix, divisor, bias));

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}

/**
 * function section
 */
public function _emboss( pic:Bitmap ):Object 
{
	var bd1:BitmapData = new BitmapData( pic.width, pic.height, true, 0x00ffffff );
	
	bd1.draw( pic );
	
	// emboss matrix
	var matrix:Array = [-6, -3, 0,
                        -3, 9, 3,
                        0, 3, 6];

    var matrixX:Number = 3;
    var matrixY:Number = 3;
    var divisor:Number = 9;
    var bias:Number = 0;
            
	bd1.applyFilter(bd1, bd1.rect, new Point(0,0), new ConvolutionFilter(matrixX, matrixY, matrix, divisor, bias));

	Application.application.callLater(generate);
	
	return new Bitmap(bd1);		
}
