package net.vdombox.powerpack.lib.graphicapi.drawing
{
import flash.display.Graphics;
import flash.geom.Point;

import mx.binding.utils.BindingUtils;
import mx.events.PropertyChangeEvent;

public class GraphicsContext
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------	
		
	/**
	 * Constructor.
	 *  
	 * @param graphics
	 * 
	 */	 
	public function GraphicsContext(graphics:Graphics)
	{
		_graphics = graphics;
		_graphics.moveTo(0, 0);
		position = new Point(0, 0);
		stroke = new PStroke(0, 1, StrokePatternStyle.SOLID, 1);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  graphics
	//----------------------------------

	private var _graphics:Graphics;
					
	public function get graphics():Graphics
	{
		return _graphics; 
	}	
	
	//----------------------------------
	//  position
	//----------------------------------
		
	private var _position:Point; 

	[Bindable("propertyChange")]

	/**
	 * Current pen position.
	 */
	public function get position():Point
	{
		return _position.clone();	
	}
	public function set position(value:Point):void
	{
		_position = value.clone();
	}
	
	//----------------------------------
	//  stroke
	//----------------------------------

	private var _stroke:PStroke; 

	[Bindable("propertyChange")]
	public function get stroke():PStroke
	{
		return _stroke;
	}	
	public function set stroke(value:PStroke):void
	{
		var flags:uint = 0;
		
		if(_stroke)
		{
			_stroke.removeEventListener("propertyChange", _strokePropertyChangeHandler);
			
			if(_stroke.weight != value.weight)
				flags |= 1;
			if(_stroke.color != value.color)
				flags |= 1<<1;
			if(_stroke.alpha != value.alpha)
				flags |= 1<<2;
			if(_stroke.pixelHinting != value.pixelHinting)
				flags |= 1<<3;
			if(_stroke.scaleMode != value.scaleMode)
				flags |= 1<<4;
			if(_stroke.caps != value.caps)
				flags |= 1<<5;
			if(_stroke.joints != value.joints)
				flags |= 1<<6;
			if(_stroke.miterLimit != value.miterLimit)
				flags |= 1<<7;
		}
		else
			flags = 1;
		
		_stroke = value.clone();
		_stroke.addEventListener("propertyChange", _strokePropertyChangeHandler);
		
		//if(flags)
			_stroke.apply(_graphics);	
	}

 	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	private function _strokePropertyChangeHandler(event:PropertyChangeEvent):void
	{
		var propName:String = event.property.toString();
		
		if(propName!="pattern")
		{
			_stroke.apply(_graphics);
		}
	}
	
}
}