package vdom.components.edit.containers {

import flash.events.MouseEvent;	
import mx.containers.Panel;
import mx.controls.Button;
import mx.core.EdgeMetrics;

public class ClosablePanel extends Panel {
	
	protected var collapseButton:Button;
	protected var switcher:Boolean;
	private var _dataProvider:Object;
	
	public function ClosablePanel() {
		super();
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if (!collapseButton) {
			collapseButton = new Button();
			collapseButton.explicitWidth = collapseButton.explicitHeight = 16;
			
			collapseButton.focusEnabled = false;
			
			collapseButton.setStyle("upSkin", getStyle('CollapseButtonOnButtonUp'));
			collapseButton.setStyle("downSkin", getStyle('CollapseButtonOnButtonDown'));
			collapseButton.setStyle("overSkin", getStyle('CollapseButtonOnButtonOver'));
			collapseButton.setStyle("disabledSkin", getStyle('CollapseButtonOnButtonDisabled'));
			
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
			collapseButton.getExplicitOrMeasuredHeight()
		);

		collapseButton.move(
			unscaledWidth - bm.right - 10 -
			collapseButton.getExplicitOrMeasuredWidth(),
			(titleBar.height -
			collapseButton.getExplicitOrMeasuredHeight()) / 2);
	}
	
	private function collapseButton_clickHandler(event:MouseEvent):void {
		
		if(switcher) {
			collapseButton.setStyle("upSkin", getStyle('CollapseButtonOnButtonUp'));
			collapseButton.setStyle("downSkin",getStyle('CollapseButtonOnButtonDown'));
			collapseButton.setStyle("overSkin",getStyle('CollapseButtonOnButtonOver'));
			collapseButton.setStyle("disabledSkin",getStyle('CollapseButtonOnButtonDisabled'));
			height = NaN;
		} else {
			collapseButton.setStyle("upSkin", getStyle('CollapseButtonOffButtonUp'));
			collapseButton.setStyle("downSkin",getStyle('CollapseButtonOffButtonDown'));
			collapseButton.setStyle("overSkin",getStyle('CollapseButtonOffButtonOver'));
			collapseButton.setStyle("disabledSkin",getStyle('CollapseButtonOffButtonDisabled'));
			height = getStyle('headerHeight');
		}
		switcher = !switcher;
	}
}
}