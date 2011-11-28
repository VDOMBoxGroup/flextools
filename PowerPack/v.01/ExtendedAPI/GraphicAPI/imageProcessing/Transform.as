package GraphicAPI.imageProcessing
{
import GeomLib.GeomUtils;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
	
public class Transform
{
	public static const FLIP_DIRECTION_HORIZONTAL:String = "horizontal";
	public static const FLIP_DIRECTION_VERTICAL:String = "vertical";
	
	public static function flip( bitmapData:BitmapData, direction:String=FLIP_DIRECTION_HORIZONTAL ):BitmapData
	{
		var bd:BitmapData = new BitmapData( bitmapData.width, bitmapData.height, true, 0x00000000 );
		
		for (var i:int=0; i<bitmapData.width; i++)
		{
			for (var j:int=0; j<bitmapData.height; j++)
			{
				bd.setPixel32(	direction==FLIP_DIRECTION_HORIZONTAL?bitmapData.width-1-i:i, 
								direction==FLIP_DIRECTION_VERTICAL?bitmapData.height-1-j:j, 
								bitmapData.getPixel32(i,j) );
			}
		}
		
		return bd;
	}
	
	public static function crop( bitmapData:BitmapData, rect:Rectangle ):BitmapData 
	{
		var bd:BitmapData = new BitmapData( rect.width, rect.height, true, 0x00000000 );

		bd.copyPixels(bitmapData, new Rectangle(rect.x, rect.y, rect.width, rect.height), new Point()); 
		
		return bd;
	}	
	
	public static function resize( bitmapData:BitmapData, width:int, height:int ):BitmapData 
	{
		var bd:BitmapData = new BitmapData( width, height, true, 0x00000000 );		
		var matrix:Matrix = new Matrix();
		
		matrix.scale( width/bitmapData.width, height/bitmapData.height );
		
		bd.draw( bitmapData, matrix );
		
		return bd;		
	}
	
	public function rotate( bitmapData:BitmapData, angle:Number, bgColor:int=-1 ):BitmapData 
	{	
		var matrix:Matrix = new Matrix();
		matrix.rotate( angle );
		
		var rect:Rectangle = new Rectangle(0, 0, bitmapData.width, bitmapData.height);
		var points:Array = [];
		
		points.push(matrix.transformPoint(rect.topLeft));
		points.push(matrix.transformPoint(rect.bottomRight));
		points.push(matrix.transformPoint(new Point(rect.right, rect.top)));
		points.push(matrix.transformPoint(new Point(rect.left, rect.bottom)));
		
		rect = GeomUtils.size(points);
		
		matrix.translate(-rect.left, -rect.top);
		
		if(bgColor<0)
			bgColor = 0x00000000;
		else if(bgColor<0x01000000)
			bgColor += 0xff000000;
		
		var bd:BitmapData = new BitmapData( rect.width, rect.height, true, 0x00000000 );	
	
		bd.draw( bitmapData, matrix, null, null, null, true );
		
		return bd;		
	}
	
}
}