package PowerPack.customize.core.windowClasses
{
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.core.windowClasses.TitleBar;
	import mx.styles.StyleManager;
	
	use namespace mx_internal;

	public class GeneratorTitleBar extends mx.core.windowClasses.TitleBar
	{
		private var bgButtons:UIComponent;
		
		public function GeneratorTitleBar()
		{
			super();
		}
	
		protected override function placeButtons(align:String,
										unscaledWidth:Number, unscaledHeight:Number,
										leftOffset:Number, rightOffset:Number,
										cornerOffset:Number):void
	    {
	        var pad:Number = getStyle("buttonPadding");
	        var edgePad:Number = getStyle("titleBarButtonPadding");
	
			minimizeButton.setActualSize(minimizeButton.measuredWidth,
										 minimizeButton.measuredHeight);
	        maximizeButton.setActualSize(maximizeButton.measuredWidth,
										 maximizeButton.measuredHeight);
	        closeButton.setActualSize(closeButton.measuredWidth,
									  closeButton.measuredHeight);
	
			if (align == "right")
	        {
	            minimizeButton.move(
					unscaledWidth - (minimizeButton.measuredWidth +
	            	maximizeButton.measuredWidth + closeButton.measuredWidth +
					(2 * pad)) - cornerOffset - edgePad,
					edgePad);
	
				maximizeButton.move(
					unscaledWidth - (maximizeButton.measuredWidth +
	            	closeButton.measuredWidth + pad) - cornerOffset - edgePad,
					edgePad);
	
				closeButton.move(
					unscaledWidth - closeButton.measuredWidth -
					cornerOffset - edgePad,
	            	edgePad);
	        }
	        else
	        {
	            edgePad = Math.max(edgePad, leftOffset);
	
				closeButton.move(
					edgePad,
	            	edgePad);
	
				minimizeButton.move(
					pad + edgePad + closeButton.measuredWidth,
	            	edgePad);
	
				maximizeButton.move(
					edgePad + (pad * 2) +
	            	closeButton.measuredWidth + minimizeButton.measuredWidth,
	            	edgePad);
	        }
	    }
	    
    	override protected function createChildren():void
    	{
    		super.createChildren();
	    	if(!bgButtons)
	    	{
	    		bgButtons = new UIComponent();
				addChildAt(bgButtons, getChildIndex(minimizeButton));
	    	}
    	}
    		    
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
	    {
	    	super.updateDisplayList(unscaledWidth, unscaledHeight);
	    	
	    	var cornerRadius:Number = getStyle("cornerRadius")/1.5;
	    	var titleBarButtonBgColorStyle:* = getStyle("titleBarButtonBgColor");
	    	var titleBarButtonBgColor:Number = StyleManager.isValidStyleValue(titleBarButtonBgColorStyle)?
	    							 titleBarButtonBgColorStyle:
	    							 getStyle("borderColor");
	    	var borderThickness:Number = getStyle("borderThickness");
	    	var pad:Number = getStyle("buttonPadding");
	    	
	    	var leftButtonsBg:Number = Math.min(minimizeButton.x, maximizeButton.x, closeButton.x)-pad;
	    	var topButtonsBg:Number = Math.min(minimizeButton.y, maximizeButton.y, closeButton.y);
	    	var rightButtonsBg:Number = Math.max(minimizeButton.x+minimizeButton.width, 
	    		maximizeButton.x+maximizeButton.width, closeButton.x+closeButton.width)+pad;
	    	var bottomButtonsBg:Number = Math.max(minimizeButton.y+minimizeButton.height, 
	    		maximizeButton.y+maximizeButton.height, closeButton.y+closeButton.height);
	    	
	    	if(bgButtons)
	    	{    		
	    		bgButtons.graphics.clear();

	   			bgButtons.drawRoundRect(
					leftButtonsBg, topButtonsBg, 
					rightButtonsBg-leftButtonsBg, bottomButtonsBg-topButtonsBg, 
					{tl: cornerRadius, 
					tr: cornerRadius, bl: 0, br: 0},
					titleBarButtonBgColor, [1.0],
					verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));		
	   			
	   			bgButtons.drawRoundRect(
					leftButtonsBg+2, topButtonsBg+1, 
					rightButtonsBg-leftButtonsBg-4, (bottomButtonsBg-topButtonsBg)/2, 
					{tl: cornerRadius, 
					tr: cornerRadius, bl: 0, br: 0},
					0xffffff, [0.6],
					verticalGradientMatrix(0, 0, unscaledWidth, unscaledHeight));		
	    	}
	    }
			
	}
}