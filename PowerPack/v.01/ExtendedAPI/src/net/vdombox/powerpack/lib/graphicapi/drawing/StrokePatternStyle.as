package src.net.vdombox.powerpack.lib.graphicapi.drawing
{
public class StrokePatternStyle
{
	public static var dotWidthLimit:uint = 6;
	
	public static var thinDotWidth:uint = 1;
	public static var thinDashWidth:uint = 3;

	public static var spaceWidth:uint = 3;
	public static var dotWidth:uint = 3;
	public static var dashWidth:uint = 15;
	public static var wideDashWidth:uint = 24;
	
	public static const NONE:Object = {pattern:[], 
										name:"none"};
	public static const SOLID:Object = {pattern:[0], 
										name:"solid"};
	public static const INSIDEFRAME:Object = {pattern:[0], 
										name:"insideFrame"};		
	public static const DOT:Object = {pattern:[dotWidth, spaceWidth], 
										name:"dot"};
	public static const DASH:Object = {pattern:[wideDashWidth, spaceWidth+spaceWidth], 
										name:"dash"};
	public static const DASHDOT:Object = {pattern:[dashWidth, spaceWidth+spaceWidth, dotWidth, spaceWidth+spaceWidth], 
										name:"dashDot"};
	public static const DASHDOTDOT:Object = {pattern:[dashWidth, spaceWidth, dotWidth, spaceWidth, dotWidth, spaceWidth], 
										name:"dashDotDot"};
}
}
