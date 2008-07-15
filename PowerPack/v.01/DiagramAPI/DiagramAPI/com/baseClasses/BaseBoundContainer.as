package DiagramAPI.com.baseClasses
{
import ExtendedAPI.com.utils.GeomUtils;

import flash.geom.Rectangle;

import mx.collections.ArrayCollection;
import mx.containers.Box;
import mx.core.EdgeMetrics;
import mx.managers.IFocusManagerComponent;

public class BaseBoundContainer extends Box implements IFocusManagerComponent
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
    /**
     *  Constructor.
     */
     	
	public function BaseBoundContainer()
	{
		super();
		focusEnabled = true;
		mouseFocusEnabled = true;
		tabEnabled = true;	
		
		styleName = this.className;	
		
		_context = new InteractiveContext(this);
		_context.isMovable = true;
	}
	
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
	public var _context:InteractiveContext;
		
    public var _rotatePoints:ArrayCollection = new ArrayCollection(); 

    public var _resizePoints:ArrayCollection = new ArrayCollection();
     
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------  

    override public function styleChanged(styleProp:String):void 
    {
        super.styleChanged(styleProp);
    }

	override public function get viewMetrics():EdgeMetrics
	{
		var em:EdgeMetrics = super.viewMetrics;
		
		return em; 
	}	
	
	/**
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if(_rotatePoints.length==0)
        {
        	_rotatePoints.addItem(new InteractivePoint());
			_rotatePoints.addItem(new InteractivePoint());

			InteractivePoint(_rotatePoints[0])._context.snapped = true;

			InteractivePoint(_rotatePoints[0]).addEventListener(MoveEvent.MOVED, moveRotateControlHandler);			
			InteractivePoint(_rotatePoints[1]).addEventListener(MoveEvent.MOVED, moveCenterControlHandler);
			
			//rawChildren.addChild(_rotatePoints[0]);
			//rawChildren.addChild(_rotatePoints[1]);
    	}

        if(_resizePoints.length==0)
        {
        	for(var i:int=0; i<8; i++)
        	{
        		_resizePoints.addItem(new InteractivePoint());
				InteractivePoint(_resizePoints[i]).addEventListener(MoveEvent.MOVED, moveSizeControlHandler);
				rawChildren.addChild(_resizePoints[i]);
        	}
    	}

		processPoints();		
    }	
    
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        invalidateDisplayList();
    }
        
	override protected function measure():void 
	{
        super.measure(); 
	}
	
	/**
	 *  @private
	 */
	override protected function layoutChrome(unscaledWidth:Number,
											 unscaledHeight:Number):void
	{
		super.layoutChrome(unscaledWidth, unscaledHeight);
		
        processPoints();                      
	}
		
	override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
	}

	protected function processPoints(forcePoints:Boolean=false):void
	{
		var p:InteractivePoint;
		var p1:InteractivePoint;
		var p2:InteractivePoint;
		var rect:Rectangle;
		
		// process size control points		
		if(_resizePoints.length>0)
		{	
			if(forcePoints)
			{
				rect = GeomUtils.getObjectsRect(_resizePoints);
				
				x += rect.x;
				y += rect.y; 
				
				width = rect.width;
				height = rect.height;
				
			}
	
			InteractivePoint(_resizePoints[0]).move(0,0);
			InteractivePoint(_resizePoints[1]).move((getExplicitOrMeasuredWidth()-InteractivePoint(_resizePoints[1]).width)/2, 0);
			InteractivePoint(_resizePoints[2]).move(getExplicitOrMeasuredWidth()-InteractivePoint(_resizePoints[2]).width, 0);
			
			InteractivePoint(_resizePoints[3]).move(getExplicitOrMeasuredWidth()-InteractivePoint(_resizePoints[3]).width,
				(getExplicitOrMeasuredHeight()-InteractivePoint(_resizePoints[3]).height)/2);
	
			InteractivePoint(_resizePoints[4]).move(getExplicitOrMeasuredWidth()-InteractivePoint(_resizePoints[4]).width,
				getExplicitOrMeasuredHeight()-InteractivePoint(_resizePoints[4]).height);
			InteractivePoint(_resizePoints[5]).move((getExplicitOrMeasuredWidth()-InteractivePoint(_resizePoints[5]).width)/2,
				getExplicitOrMeasuredHeight()-InteractivePoint(_resizePoints[5]).height);
			InteractivePoint(_resizePoints[6]).move(0,getExplicitOrMeasuredHeight()-InteractivePoint(_resizePoints[6]).height);
	
			InteractivePoint(_resizePoints[7]).move(0,(getExplicitOrMeasuredHeight()-InteractivePoint(_resizePoints[7]).height)/2);
			
			for each (var points:ArrayCollection in [_resizePoints])
				for each (var obj:InteractivePoint in points) 
				{
					if(_context.focused) 
					{
						obj.visible = true;
						obj._context.bringToFront();
					}
					else
						obj.visible = false;					
				}			
		}		
		
		// process rotate control points
		
	}	
	
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    private function moveCenterControlHandler(event:MoveEvent):void
    {
    	invalidateSize();
		invalidateDisplayList();    	
    }      

    private function moveRotateControlHandler(event:MoveEvent):void
    {
    	invalidateSize();
		invalidateDisplayList();    	
    }      

    private function moveSizeControlHandler(event:MoveEvent):void
    {
    	var  p:InteractivePoint = event.target as InteractivePoint;
    	
    	if(p==_resizePoints[0] || p==_resizePoints[1] || p==_resizePoints[2])
    	{
    		_resizePoints[0].move(_resizePoints[0].x, p.y);
    		_resizePoints[1].move(_resizePoints[1].x, p.y);
    		_resizePoints[2].move(_resizePoints[2].x, p.y);
    	}
    	if(p==_resizePoints[2] || p==_resizePoints[3] || p==_resizePoints[4])
    	{
    		_resizePoints[2].move(p.x, _resizePoints[2].y);
    		_resizePoints[3].move(p.x, _resizePoints[3].y);
    		_resizePoints[4].move(p.x, _resizePoints[4].y);    		
    	}
    	if(p==_resizePoints[4] || p==_resizePoints[5] || p==_resizePoints[6])
    	{
    		_resizePoints[4].move(_resizePoints[4].x, p.y);
    		_resizePoints[5].move(_resizePoints[5].x, p.y);
    		_resizePoints[6].move(_resizePoints[6].x, p.y);
    	}
    	if(p==_resizePoints[6] || p==_resizePoints[7] || p==_resizePoints[0])
    	{
    		_resizePoints[6].move(p.x, _resizePoints[6].y);
    		_resizePoints[7].move(p.x, _resizePoints[7].y);
    		_resizePoints[0].move(p.x, _resizePoints[0].y);    		
    	}
    	
    	processPoints(true);
    	
    	invalidateSize();
		invalidateDisplayList();    	
    }
    
}
}