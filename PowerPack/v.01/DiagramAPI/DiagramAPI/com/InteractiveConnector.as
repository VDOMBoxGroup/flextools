package DiagramAPI.com
{
import DiagramAPI.com.baseClasses.BaseConnector;
import DiagramAPI.com.baseClasses.InteractiveContext;
import DiagramAPI.com.baseClasses.InteractivePoint;
import DiagramAPI.com.baseClasses.MoveEvent;

import ExtendedAPI.com.utils.GeomUtils;

import flash.filters.GradientGlowFilter;
import flash.geom.Rectangle;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.managers.IFocusManagerComponent;
import mx.styles.CSSStyleDeclaration;
import mx.styles.StyleManager;

//--------------------------------------
//  Events
//--------------------------------------	

//--------------------------------------
//  Styles
//--------------------------------------

[Style(name="defaultColor", type="uint", format="Color", inherit="no")]
[Style(name="disabledColor", type="uint", format="Color", inherit="yes")]

[Style(name="rollOverColor", type="uint", format="Color", inherit="yes")]
[Style(name="selectionColor", type="uint", format="Color", inherit="yes")]
[Style(name="highlightColor", type="uint", format="Color", inherit="no")]

[Style(name="outlineRollOverColor", type="uint", format="Color", inherit="no")]
[Style(name="outlineSelectionColor", type="uint", format="Color", inherit="no")]
[Style(name="outlineHighlightColor", type="uint", format="Color", inherit="no")]

[Style(name="outlineAlpha", type="Number", format="Length", inherit="no")]
[Style(name="outlineThickness", type="Number", format="Length", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

//[IconFile("InteractiveConnector.png")]

//[ExcludeClass]

public class InteractiveConnector extends BaseConnector implements IFocusManagerComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
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
    	var className:String = "InteractiveConnector";
    	
        if (!StyleManager.getStyleDeclaration(className))
        {
            // If there is no CSS definition for Connector, 
            // then create one and set the default value.
            var newStyleDeclaration:CSSStyleDeclaration;
            
            if(!(newStyleDeclaration = StyleManager.getStyleDeclaration("BaseConnector")))
            {
                newStyleDeclaration = new CSSStyleDeclaration();
                newStyleDeclaration.setStyle("themeColor", "haloBlue");
            }

            newStyleDeclaration.setStyle("defaultColor", 0x000000);
            newStyleDeclaration.setStyle("rollOverColor", 0x000077);
            newStyleDeclaration.setStyle("selectionColor", 0x000000);
            newStyleDeclaration.setStyle("highlightColor", 0xffffff);
            newStyleDeclaration.setStyle("disabledColor",  0x666666);
            
            newStyleDeclaration.setStyle("outlineThickness", 2);
            newStyleDeclaration.setStyle("outlineRollOverColor", newStyleDeclaration.getStyle("themeColor"));
            newStyleDeclaration.setStyle("outlineSelectionColor", newStyleDeclaration.getStyle("themeColor"));
            newStyleDeclaration.setStyle("outlineHighlightColor", newStyleDeclaration.getStyle("themeColor"));                
            newStyleDeclaration.setStyle("outlineAlpha", 0.4);
            
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
	public function InteractiveConnector()
	{
		super();
		
		focusEnabled = true;
		mouseFocusEnabled = true;
		tabEnabled = true;	
		tabChildren = false;
		
		styleName = this.className;
		
		_context = new InteractiveContext(this);
		_context.isMovable = true;
		_showControls = true;
	}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------  
	
	public var _context:InteractiveContext;
	
	private var _controlSprite:UIComponent;
	
	public var _showControls:Boolean;
    private var _oldFocused:Boolean;
    private var _oldOver:Boolean;

    //--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

    //----------------------------------
    //  highlight
    //----------------------------------
    
    private var _highlighted:Boolean = false;
	private var _highlightedChanged:Boolean = false;
	
    [Bindable("highlightedChanged")]
    [Inspectable(category="General", enumeration="true,false", defaultValue="false")]

    public function get highlighted():Boolean
    {
        return _highlighted;
    }	
    public function set highlighted(value:Boolean):void
    {
		if(_highlighted!=value)
		{
        	_highlighted = value;
        	_highlightedChanged = true;
        
        	invalidateProperties();
			         
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.HIGHLIGHTED_CHANGED));
  		}
    }

    //----------------------------------
    //  enabled
    //----------------------------------
   	    
    private var _enabled:Boolean = true;
	private var _enabledChanged:Boolean = false;
	
    [Bindable("enabledChanged")]
    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]

    override public function get enabled():Boolean
    {
        return _enabled;
    }   
    override public function set enabled(value:Boolean):void
    {
    	if(_enabled != value)
    	{
    		super.enabled = value;
    	
        	_enabled = value;
        	_enabledChanged = true;
        
	        invalidateProperties();
			         
    	    dispatchEvent(new ConnectorEvent(ConnectorEvent.ENABLED_CHANGED));
    	}
    }	

    //----------------------------------
    //  data
    //----------------------------------
    
    private var _data:Object;

    [Bindable("dataChanged")]
    [Inspectable(category="General")]

    public function get data():Object
    {
        return _data;
    }
    public function set data(value:Object):void
    {
    	if(_data != value)
    	{
        	_data = value;	   
        	
        	invalidateProperties();
        	      
        	dispatchEvent(new ConnectorEvent(ConnectorEvent.DATA_CHANGED));
     	}
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
        
        if(!_controlSprite) 
        {
        	_controlSprite = new UIComponent();
        	addChild(_controlSprite);
       		_controlSprite.visible = false;

			_anchorPoints[0].type = InteractivePoint.CONNECTOR; 
			_anchorPoints[1].type = InteractivePoint.CONNECTOR; 	
		
			_controlSprite.addChild(_anchorPoints[0]);			
			_controlSprite.addChild(_anchorPoints[1]);
			
			InteractivePoint(_anchorPoints[0]).addEventListener(MoveEvent.MOVED, moveAnchorHandler);			
			InteractivePoint(_anchorPoints[1]).addEventListener(MoveEvent.MOVED, moveAnchorHandler);
			
			processPoints();
    	}
    }

    override protected function commitProperties():void
    {
        super.commitProperties();

        if (_enabledChanged)
        {
            _enabledChanged = false;

            invalidateSize();
            invalidateDisplayList();
        }

        if (_highlightedChanged)
        {
            _highlightedChanged = false;
            
            invalidateSize();
            invalidateDisplayList();
        }

		if(_oldOver != _context.over)
		{
			_oldOver = _context.over;
			
	       	invalidateSize();
          	invalidateDisplayList();			
		}

		if(_oldFocused != _context.focused)
		{
			_oldFocused = _context.focused;
			
			showControlPoints();
					
	       	invalidateSize();
          	invalidateDisplayList();			
		}
		
    }
    
	override protected function measure():void 
	{
		processPoints();
		                      
        super.measure();

		var rect:Rectangle = new Rectangle(0,0,measuredWidth,measuredHeight);

		var offset:Number = 0;
		
   		if(enabled && (_highlighted || _context.over || _context.focused))
   		{
        	offset = getStyle("outlineThickness");
	        
	        if(_anchorPoints.length && _controlSprite.visible) {
    	    	offset +=
        			Math.max(InteractivePoint(_anchorPoints[0]).width/2-(offset+getStyle("strokeWidth")/2), 0);	            
        	}        	
     	}     	

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
		if(!_anchorPoints || _anchorPoints.length<2)
			return;
		
		var color:Number = getStyle("defaultColor");
		
		if(!_enabled)			{ color=getStyle("disabledColor"); }
		else if(_highlighted)	{ color=getStyle("highlightColor"); }
		else if(_context.over)			{ color=getStyle("rollOverColor"); }
		else if(_context.focused)		{ color=getStyle("selectionColor"); }		
					
		super.setStyle("color", color);
		
		var outlineColor:Number = -1;
							
		if(_highlighted)		{ outlineColor=getStyle("outlineHighlightColor"); }
		else if(_context.over)			{ outlineColor=getStyle("outlineRollOverColor"); }
		else if(_context.focused)		{ outlineColor=getStyle("outlineSelectionColor"); }

		super.updateDisplayList(unscaledWidth, unscaledHeight);	

		// Draw outline		
		_sprite.filters = [];
		if(outlineColor>=0 && enabled)
		{
			var oThickness:uint = getStyle("outlineThickness")*2;
			var oAlpha:Number = getStyle("outlineAlpha");

			var outlineFilter:GradientGlowFilter = new GradientGlowFilter(
				0, 0,
				[outlineColor, outlineColor, outlineColor], 
				[0, oAlpha, oAlpha],
				[0, 2, 255], 
				oThickness, oThickness, 
				1, 1, 'outer');
			
			var fArr:Array = [outlineFilter];
			_sprite.filters = fArr;
		}		

		// draw border rect
		//graphics.lineStyle(1, 0x00ff00, 1);
		//graphics.drawRect(0, 0, unscaledWidth-1, unscaledHeight-1);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	protected function showControlPoints():void
	{
		if(_context.focused && _showControls)
			_controlSprite.visible = true;
		else
			_controlSprite.visible = false;
	}
	
	override protected function processPoints(rebuild:Boolean=false):void
	{
		super.processPoints(rebuild);
		
		for each (var points:ArrayCollection in [_controlPoints, _controlPoints2])
			for each (var obj:InteractivePoint in points) {
				if(!obj.parent && _controlSprite) {
					_controlSprite.addChild(obj);
					obj._context.isMovable = false;
					obj.move(obj.x, obj.y);
				}
			}		
	}	
	
	//--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    private function moveAnchorHandler(event:MoveEvent):void
    {
    	
    	invalidateSize();
		invalidateDisplayList();    	
    }
    
    private function moveControlHandler(event:MoveEvent):void
    {
    	invalidateSize();
		invalidateDisplayList();
    }

    private function moveControl2Handler(event:MoveEvent):void
    {
    	invalidateSize();
		invalidateDisplayList();    	
    }

    private function moveStraightControlHandler(event:MoveEvent):void
    {
    	invalidateSize();
		invalidateDisplayList();    	
    }
    
}
}