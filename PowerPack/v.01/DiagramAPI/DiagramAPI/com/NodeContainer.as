package DiagramAPI.com
{	
import DiagramAPI.com.baseClasses.BaseBoundContainer;
import DiagramAPI.com.baseClasses.InteractiveContext;
import DiagramAPI.com.baseClasses.InteractivePoint;

import flash.events.MouseEvent;
import flash.filters.GlowFilter;

import mx.binding.utils.*;
import mx.collections.ArrayCollection;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

public class NodeContainer extends BaseBoundContainer
{
	//--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    public static const TEXT_WIDTH_PADDING:int = 5;
    public static const TEXT_HEIGHT_PADDING:int = 4;
    
    /**
    * default minimum node size
    */
    public static const DEFAULT_WIDTH:Number = 30;
    public static const DEFAULT_HEIGHT:Number = 20;
    
    /**
    * text area right padding
    */
    public static const PADDING:Number = 0;
    		
	/**
	 *	defines current node state values
	 */
    
    //--------------------------------------------------------------------------
    //
    //  Variables and properties
    //
    //--------------------------------------------------------------------------
    
    // Define a static variable.
    private static var _classConstructed:Boolean = classConstruct();
    
    public static function get classConstructed():Boolean
    {
    	return _classConstructed;
    }
    
    // Define a static method.
    private static function classConstruct():Boolean 
    {
        if (!StyleManager.getStyleDeclaration("NodeContainer"))
        {
            // If there is no CSS definition for the component, 
            // then create one and set the default value.
            var newStyleDeclaration:CSSStyleDeclaration;
            
            if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("Box")))
            {
                newStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("themeColor", "haloBlue");
            }     
		
			newStyleDeclaration.setStyle( "borderStyle", "solid" );
			newStyleDeclaration.setStyle( "borderThickness", 1);
			newStyleDeclaration.setStyle( "borderColor", 0xE2E2E2);			
			newStyleDeclaration.setStyle( "backgroundColor", 0xE2E2E2 );
			newStyleDeclaration.setStyle( "backgroundAlpha", 0.5 );

			newStyleDeclaration.setStyle( "paddingLeft", 2 );
			newStyleDeclaration.setStyle( "paddingRight", 2 );
			newStyleDeclaration.setStyle( "paddingTop", 2 );
			newStyleDeclaration.setStyle( "paddingBottom", 2 );
			                
            StyleManager.setStyleDeclaration("NodeContainer", newStyleDeclaration, true);
        }
	
        return true;
    }        
    
	//--------------------------------------------------------------------------   
	
    [ArrayElementType("Connector")]
    public var connectors:ArrayCollection = new ArrayCollection();
    
    public var _holderPoints:ArrayCollection = new ArrayCollection();
    public var holderArea:Number = 0.5;
    
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	public function NodeContainer()
	{
		super();
		
		doubleClickEnabled = true;
		cacheAsBitmap = true;
	}		
			
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
     *  Create child objects.
     */
    override protected function createChildren():void
    {
        super.createChildren();
    	
    	if(_holderPoints.length==0)
    	{
    		for(var i:int=0; i<4; i++)
    		{
    			_holderPoints.addItem(new InteractivePoint());
				InteractivePoint(_holderPoints[i]).type = InteractivePoint.HOLDER;					
				InteractivePoint(_holderPoints[i])._context.isMovable = false;
				InteractivePoint(_holderPoints[i]).addEventListener(MouseEvent.ROLL_OVER, holderOverHandler);
				InteractivePoint(_holderPoints[i]).addEventListener(MouseEvent.ROLL_OUT, holderOutHandler);
				rawChildren.addChild(_holderPoints[i]);
    		}
    		
    		processPoints();
		}	        
    }
	
	override protected function processPoints(forcePoints:Boolean=false):void
	{
		super.processPoints(forcePoints);
		
		if(_holderPoints.length>0)
		{
			InteractivePoint(_holderPoints[0]).move((getExplicitOrMeasuredWidth()-InteractivePoint(_holderPoints[0]).width)/2, 0);
			
			InteractivePoint(_holderPoints[1]).move(getExplicitOrMeasuredWidth()-InteractivePoint(_holderPoints[1]).width,
				(getExplicitOrMeasuredHeight()-InteractivePoint(_holderPoints[1]).height)/2);
	
			InteractivePoint(_holderPoints[2]).move((getExplicitOrMeasuredWidth()-InteractivePoint(_holderPoints[2]).width)/2,
				getExplicitOrMeasuredHeight()-InteractivePoint(_resizePoints[2]).height);

			InteractivePoint(_holderPoints[3]).move(0,(getExplicitOrMeasuredHeight()-InteractivePoint(_holderPoints[3]).height)/2);
		}			
	}
	
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        var cP:InteractivePoint = InteractiveContext.movingObj as InteractivePoint;
        
        if(cP && 
    		cP is InteractivePoint && 
    		cP.type==InteractivePoint.CONNECTOR)
        {
        	if(_context._over && !cP._context.snapped)
        	{
    			cP._context.snapTo(this);
        	}
        }        	
        
		invalidateDisplayList();	        
    }    

	override protected function measure():void 
	{
        super.measure();
    }        
    
    override protected function updateDisplayList(unscaledWidth:Number,
											  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		this.filters = [];
        if(_context._over)
        {
			var filter:GlowFilter = new GlowFilter(0xff0000, 0.7, 6, 6, 5);
    		this.filters = [filter];
        }

	}

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------		
	
		    	    
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
	
    private function holderOverHandler(event:MouseEvent):void
    {
    	var hP:InteractivePoint = event.target as InteractivePoint;
    	var cP:InteractivePoint = InteractiveContext.movingObj as InteractivePoint;
    	
    	if(hP!=cP && cP && 
    		cP is InteractivePoint && 
    		cP.type==InteractivePoint.CONNECTOR) 
    	{
    		var filter:GlowFilter = new GlowFilter(0xff0000, 0.7, 6, 6, 5);
    		hP.filters = [filter];
    		cP._context.snapTo(hP);
    	}
    }

    private function holderOutHandler(event:MouseEvent):void
    {
    	var hP:InteractivePoint = event.target as InteractivePoint;
    	var cP:InteractivePoint = InteractiveContext.movingObj as InteractivePoint;
    	
		hP.filters = [];    		
    	if(hP!=cP && cP && 
    		cP is InteractivePoint && 
    		cP.type==InteractivePoint.CONNECTOR) 
    	{
    		//cP._context.unsnapFrom();
    	}
    }
    
}
}