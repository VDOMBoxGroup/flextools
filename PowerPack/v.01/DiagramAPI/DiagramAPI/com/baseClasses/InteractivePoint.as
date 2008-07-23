package DiagramAPI.com.baseClasses
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.Point;

import mx.core.UIComponent;
import mx.managers.IFocusManagerComponent;

public class InteractivePoint extends UIComponent implements IFocusManagerComponent
{
	private static const INTERACTIVE_AREA:uint = 20;
	private static const SIZE:uint = 10;
	
	public static const CONNECTOR:String = "connector";
	public static const CONTROL:String = "control";
	public static const HOLDER:String = "holder";
	
	public function InteractivePoint(centerX:Number=0, centerY:Number=0)
	{
		super();
		
		focusEnabled = false;
		
		_context = new InteractiveContext(this);		
		_context.isMovable = true;

        _context.centerX = centerX; 			
		_context.centerY = centerY;
	}
	
	public var _context:InteractiveContext;
    private var _created:Boolean = false;
    public var type:String = CONTROL;

    override protected function createChildren():void
    {
        super.createChildren();
    }
	
	override protected function commitProperties():void 
	{
    	super.commitProperties();
	}
        
	override protected function measure():void 
	{
        super.measure();
        
        measuredMinWidth = measuredWidth = INTERACTIVE_AREA;
        measuredMinHeight = measuredHeight = INTERACTIVE_AREA;        
        
        if(!_created)
        {
        	_created = true;
         	
         	if(isNaN(explicitWidth) && isNaN(percentWidth))        	
        		_context.centerX = x+measuredWidth/2; 			
			
         	if(isNaN(explicitWidth) && isNaN(percentWidth))        	
        		_context.centerY = y+measuredHeight/2; 			
			
			setActualSize(getExplicitOrMeasuredWidth(),
   	    				getExplicitOrMeasuredHeight());			
        }
	}

	override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);	

		var g:Graphics = graphics;
		
		g.clear();				
		
		g.lineStyle(0, 0x000000, 0.0);		
		g.beginFill(0x000000, 0.1)
		g.drawRect(0, 0, unscaledWidth, unscaledHeight);
		g.endFill();
		
		var p1:Point = new Point((unscaledWidth-SIZE)/2, (unscaledHeight-SIZE)/2);
		
		g.lineStyle(0, 0x00ff00, 1);
		g.drawRect(p1.x, p1.y, SIZE, SIZE);
	}
    
}
}