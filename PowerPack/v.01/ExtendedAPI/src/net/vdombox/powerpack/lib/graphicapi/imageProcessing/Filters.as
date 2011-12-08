package src.net.vdombox.powerpack.lib.graphicapi.imageProcessing
{
import src.net.vdombox.powerpack.lib.graphicapi.GraphicUtils;

import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.GradientType;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
	
public class Filters
{
	public static function reflection(bitmapData:BitmapData, thickness:int=0, alpha:Number=0.5):BitmapData
	{
		var bd:BitmapData;
		
		if(thickness<=0)
			thickness = bitmapData.height/4;
			
		var shape:Shape = new Shape();
		var gradientBoxMatrix:Matrix = new Matrix();
		gradientBoxMatrix.createGradientBox(bitmapData.width, thickness, Math.PI/2, 0, 0);		
		shape.graphics.beginGradientFill(GradientType.LINEAR, [0x000000, 0x000000], [0.0, alpha], [0, 255], gradientBoxMatrix);
		shape.graphics.drawRect(0, 0, bitmapData.width, thickness);
		shape.graphics.endFill();
		
		bd = GraphicUtils.objToBitmapData(shape);		
		var rect:Rectangle = bitmapData.rect;
		
		rect.top += rect.height - thickness;
		
		bd.copyChannel(bitmapData, rect, new Point(), BitmapDataChannel.RED, BitmapDataChannel.RED);
		bd.copyChannel(bitmapData, rect, new Point(), BitmapDataChannel.GREEN, BitmapDataChannel.GREEN);
		bd.copyChannel(bitmapData, rect, new Point(), BitmapDataChannel.BLUE, BitmapDataChannel.BLUE);
		
		bd = Transform.flip(bd, Transform.FLIP_DIRECTION_VERTICAL);
		return bd;
	}
}
}