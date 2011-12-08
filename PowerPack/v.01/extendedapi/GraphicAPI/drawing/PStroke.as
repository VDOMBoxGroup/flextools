package GraphicAPI.drawing
{
import flash.display.CapsStyle;

import mx.events.PropertyChangeEvent;
import mx.graphics.Stroke;

/**
 * The PStroke class defines the properties for a line.
 *
 * @see mx.graphics.Stroke
 */
public class PStroke extends mx.graphics.Stroke
{
    /**
     * @private
     */	
    internal var drawing:Boolean = true;
    /**
     * @private
     */    
    internal var patternIndex:int = 0;
    /**
     * @private
     */    
    internal var offset:Number = 0.0;    

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *  
	 * @param color
	 * @param weight
	 * @param pattern
	 * @param alpha
	 * @param pixelHinting
	 * @param scaleMode
	 * @param caps
	 * @param joints
	 * @param miterLimit
	 * 
	 */
	public function PStroke(color:uint=0, weight:Number=0, pattern:Object=null, 
							alpha:Number=1, pixelHinting:Boolean=false, 
							scaleMode:String="normal", caps:String=null, 
							joints:String=null, miterLimit:Number=0)
	{
		super(color, weight, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
		this.pattern = pattern;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  alpha
	//----------------------------------
	
    private var _alphaMem:Number = 0.0;
    
    /**
     * @private
     */
    public override function get alpha():Number
    {
    	return super.alpha;
    }
    public override function set alpha(value:Number):void
    {
		super.alpha = value;
    	_alphaMem = value;
    }
    
	//----------------------------------
	//  visible
	//----------------------------------
	
	[Bindable("propertyChange")]
    public function get visible():Boolean
    {
    	return (super.alpha>0?true:false);
    }
    public function set visible(value:Boolean):void
    {
    	var oldValue:Boolean = visible;
    	
    	if(value != oldValue)
    	{
    		if(value)
    			super.alpha = _alphaMem;
    		else
    			super.alpha = 0.0;	   
    	
    		_dispatchStrokeChangedEvent("visible", oldValue, value);
    	} 	
    }
    
	//----------------------------------
	//  pattern
	//----------------------------------
	
	private var _pattern:Array;
	
	[Bindable("propertyChange")]
	/**
	 *  The line pattern. 
	 *  
	 *  @default null (solid line) 
	 */
    public function get pattern():Object
    {
        return _pattern;
    }		
    public function set pattern(value:Object):void
    {
    	var oldValue:Array = _pattern;
    	var oldType:Object = _patternType;
    	var bChanged:Boolean = false;
    	
    	var __pattern:Array = null;
    	var __patternType:Object = null;
    	
		if(value==null)
		{
			__patternType = StrokePatternStyle.SOLID;				
		}
		else if(value is Array)
		{
			if(value.length==0)
				__patternType = StrokePatternStyle.NONE;				
			else if(value.length==1 && value[0]==0)
				__patternType = StrokePatternStyle.SOLID;				
			else
				__pattern = value.concat();
		}
		else if(value.hasOwnProperty('pattern') && value.hasOwnProperty('name'))
		{
			__patternType = value;				
		}
		
		bChanged = true;
		if(__patternType && oldType && __patternType.name==oldType.name)
		{
			bChanged = false;
		}
		
		if(bChanged)
		{
			_patternType = __patternType;
			_pattern = __pattern;
			
    		if(_patternType)
    			_pattern = _processStrokePattern(_patternType.pattern);
    	
    		refreshPattern();
    	
    		_dispatchStrokeChangedEvent("pattern", oldValue, _pattern);
  		}
    }
	
	//----------------------------------
	//  patternType
	//----------------------------------
	    
	private var _patternType:Object;
	
    public function get patternType():Object
    {
        return _patternType;
    }
    
	//----------------------------------
	//  patternName
	//----------------------------------

    public function get patternName():String
    {
    	if(_patternType)
        	return _patternType.name;
        return null;
    }	
	
	//----------------------------------
	//  weight
	//----------------------------------
	
    /**
     * @private
     */
    public override function set weight(value:Number):void
    {
    	var oldValue:Number = super.weight; 
    	
    	if(value!=oldValue)
    	{
    		super.weight = value; 
	   		if(_patternType)
    			_pattern = _processStrokePattern(_patternType.pattern);
    	}
    }
    
	//----------------------------------
	//  caps
	//----------------------------------

    /**
     * @private
     */
    public override function set caps(value:String):void
    {
    	var oldValue:String = super.caps; 
    	
    	if(value!=oldValue)
    	{    	
    		super.caps = value;	

    		if(_patternType)
    			_pattern = _processStrokePattern(_patternType.pattern);
    	}
    }
    
 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    public function refreshPattern():void
    {
    	drawing = true;
    	patternIndex = 0;
    	offset = 0;
    	
    	if(pattern && pattern.length>0)
    	{
    		drawing = false;
    		if(pattern.length>1)
		    	patternIndex = 1;
    	}
    }

	public function clone():PStroke
	{
		var clone:PStroke = new PStroke(
			this.color, 
			this.weight, 
			null, 
			this._alphaMem, 
			this.pixelHinting, 
			this.scaleMode, 
			this.caps, 
			this.joints,
			this.miterLimit);

		if(this.patternType)
			clone.pattern = this.patternType;
		else if(this._pattern)
			clone.pattern = this._pattern.concat();
		
		clone.visible = this.visible;
		clone.drawing = this.drawing;
		clone.offset = this.offset;
		clone.patternIndex = this.patternIndex;	
		
		return clone;	
	}		
	
	/**
	 *  @private
	 */
	private function _dispatchStrokeChangedEvent(prop:String, oldValue:*,
												value:*):void
	{
        dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop,
															oldValue, value));
	}   
	
    /**
     * @private
     */
	private function _processStrokePattern(pattern:Array):Array
	{
		if(pattern==null)
			return null;
		if(pattern.length==0)
			return [];
		if(pattern.length==1 && pattern[0]==0)
			return [0];
		
		var retArr:Array = pattern.concat();
		
		for(var i:int=0; i<retArr.length; i++)
		{
			if(retArr[i]<=StrokePatternStyle.dotWidthLimit)
				retArr[i] = Math.max(StrokePatternStyle.thinDotWidth*this.weight, retArr[i]);
			else
				retArr[i] = Math.max(StrokePatternStyle.thinDashWidth*this.weight, retArr[i]);
		
			if(this.caps != CapsStyle.NONE)
			{
				if(i%2) 
					retArr[i] += this.weight;
				else
					retArr[i] -= this.weight;
			}

			retArr[i] = retArr[i]?retArr[i]:1;
		}
		
		return retArr;
	} 

}
}