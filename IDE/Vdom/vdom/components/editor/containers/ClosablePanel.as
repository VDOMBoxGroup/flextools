package vdom.components.editor.containers {

import flash.events.MouseEvent;	
import mx.containers.Panel;
import mx.controls.Button;
import mx.core.EdgeMetrics;

public class ClosablePanel extends Panel {
	
	private var collapseButton:Button;
	protected var switcher:Boolean;
	private var _dataProvider:Object;
	
	public function ClosablePanel() {
		super();
	}
	
	override protected function createChildren():void {
		
	    super.createChildren();
	    setStyle('headerHeight', '30');
	    if (!collapseButton) {
	        collapseButton = new Button();
	        collapseButton.explicitWidth = collapseButton.explicitHeight = 16;
	        
	        collapseButton.focusEnabled = false;
	        collapseButton.setStyle("upSkin", CollOnButtonUp);
	        collapseButton.setStyle("downSkin", CollOnButtonDown);
	        collapseButton.setStyle("overSkin", CollOnButtonOver);
	        collapseButton.setStyle("disabledSkin", CollOnButtonDisabled);
	        collapseButton.enabled = enabled;
	        collapseButton.styleName = this;	
	        
	        collapseButton.addEventListener(MouseEvent.CLICK, collapseButton_clickHandler);
	       
	        titleBar.addChild(collapseButton);
			collapseButton.owner = this;
	   }  
	}
	
	override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void {
		
		super.layoutChrome(unscaledWidth, unscaledHeight);
		var bm:EdgeMetrics = borderMetrics;

		collapseButton.setActualSize(
	        collapseButton.getExplicitOrMeasuredWidth(),
	        collapseButton.getExplicitOrMeasuredHeight());

    	collapseButton.move(
	        unscaledWidth - bm.right - 10 -
	        collapseButton.getExplicitOrMeasuredWidth(),
	        (titleBar.height -
	        collapseButton.getExplicitOrMeasuredHeight()) / 2);
	}
	
	private function collapseButton_clickHandler(event:MouseEvent):void {
		
		if(switcher) {
			collapseButton.setStyle("upSkin", CollOnButtonUp);
	        collapseButton.setStyle("downSkin",CollOnButtonDown);
	        collapseButton.setStyle("overSkin",CollOnButtonOver);
	        collapseButton.setStyle("disabledSkin",CollOnButtonDisabled);
			height = NaN;
		} else {
			collapseButton.setStyle("upSkin", CollOffButtonUp);
	        collapseButton.setStyle("downSkin",CollOffButtonDown);
	        collapseButton.setStyle("overSkin",CollOffButtonOver);
	        collapseButton.setStyle("disabledSkin",CollOffButtonDisabled);
			height = getStyle('headerHeight');
		}
		switcher = !switcher;
	}
}
}