package net.vdombox.PowerPack.customize.skins
{

import mx.skins.Border;
import mx.styles.StyleManager;

/**
 *  The skin for a ProgressBar.
 */
public class GeneratorProgressBarSkin extends Border
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function GeneratorProgressBarSkin()
	{
		super();		
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  measuredWidth
    //----------------------------------
    
    /**
     *  @private
     */    
    override public function get measuredWidth():Number
    {
        return 200;
    }
    
    //----------------------------------
	//  measuredHeight
    //----------------------------------
    
    /**
     *  @private
     */        
    override public function get measuredHeight():Number
    {
        return 6;
    }
		
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */        
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		// User-defined styles
		var barColorStyle:* = getStyle("barColor");
		var barColor:uint = StyleManager.isValidStyleValue(barColorStyle) ?
							barColorStyle :
							getStyle("themeColor");

		// default fill color for halo uses theme color
		var fillColors:Array = [ barColor, getStyle("themeColor") ]; 
				
		graphics.clear();
		
		var _l:int = 2; 
		var _w:int = w-4; 
		var _t:int = 2; 
		var _h:int = h-4;
		
		var _bW:int = getStyle("trackHeight")/2;
		var _offset:int = 2; 
		
		var _curW:int = 0;
		
		// fill
		
		if(_w>0 && _bW>0)
		{
			do
			{
				if(_curW+_bW>_w)
					_bW = _w-_curW;  

				drawRoundRect(
					_l+_curW, _t, _bW, _h, 0,
					fillColors, 1,
					verticalGradientMatrix(_l+_curW, _t, _bW, _h));

				_curW += (_bW + _offset);
				
			} while(_curW<_w)
		}
	}
}

}
