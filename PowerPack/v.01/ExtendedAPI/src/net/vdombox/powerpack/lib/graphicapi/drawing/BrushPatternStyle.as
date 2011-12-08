package src.net.vdombox.powerpack.lib.graphicapi.drawing
{
import flash.display.BitmapData;
import flash.display.Shape;

public class BrushPatternStyle
{
	public static var cellSize:uint = 6;
	public static var lineWidth:uint = 1;
	private static var _stroke:PStroke = new PStroke(0, lineWidth);
	
	public static function BDiagonal(color:uint=0):BitmapData
	{
		_stroke.color = color;
		return _getPatternBitmapData("BDiagonal", _stroke);
	}	
	public static function FDiagonal(color:uint=0):BitmapData
	{
		_stroke.color = color;
		return _getPatternBitmapData("FDiagonal", _stroke);
	}	
	public static function Cross(color:uint=0):BitmapData
	{
		_stroke.color = color;
		return _getPatternBitmapData("Cross", _stroke);
	}	
	public static function DiagCross(color:uint=0):BitmapData
	{
		_stroke.color = color;
		return _getPatternBitmapData("DiagCross", _stroke);
	}	
	public static function Horizontal(color:uint=0):BitmapData
	{
		_stroke.color = color;
		return _getPatternBitmapData("Horizontal", _stroke);
	}	
	public static function Vertical(color:uint=0):BitmapData
	{
		_stroke.color = color;
		return _getPatternBitmapData("Vertical", _stroke);
	}	
		
	/**
	 * @private
	 */
	private static function _getPatternBitmapData(style:String, stroke:PStroke):BitmapData
	{
		var shape:Shape = new Shape();
		stroke.apply(shape.graphics);
		
		switch (style) 
		{
			case 'BDiagonal':
			case 'FDiagonal':
			case 'DiagCross':
				shape.graphics.moveTo(cellSize-1,-1);			
				shape.graphics.lineTo(cellSize+1,1);
				shape.graphics.moveTo(-1,cellSize-1);			
				shape.graphics.lineTo(1,cellSize+1);

				shape.graphics.moveTo(1,-1);			
				shape.graphics.lineTo(-1,1);
				shape.graphics.moveTo(cellSize+1,cellSize-1);			
				shape.graphics.lineTo(cellSize-1,cellSize+1);
				break;	
		}

		switch (style) 
		{
			case 'BDiagonal':
				shape.graphics.moveTo(0,0);			
				shape.graphics.lineTo(cellSize,cellSize);
				break;
			case 'FDiagonal':
				shape.graphics.moveTo(cellSize,0);			
				shape.graphics.lineTo(0,cellSize);
				break;
			case 'DiagCross':
				shape.graphics.moveTo(0,0);			
				shape.graphics.lineTo(cellSize,cellSize);
				shape.graphics.moveTo(cellSize,0);			
				shape.graphics.lineTo(0,cellSize);
				break;
			case 'Cross':
				shape.graphics.moveTo(cellSize/2,0);			
				shape.graphics.lineTo(cellSize/2, cellSize);
				shape.graphics.moveTo(0, cellSize/2);			
				shape.graphics.lineTo(cellSize, cellSize/2);
				break;
			case 'Horizontal':
				shape.graphics.moveTo(0,cellSize/2);			
				shape.graphics.lineTo(cellSize,cellSize/2);
				break;
			case 'Vertical':
				shape.graphics.moveTo(cellSize/2,0);			
				shape.graphics.lineTo(cellSize/2,cellSize);
				break;
		}
		
		var bitmapData:BitmapData = new BitmapData(cellSize, cellSize, true, 0x00ffffff);
		bitmapData.draw(shape);
		
		return bitmapData;
	} 
	
}
}