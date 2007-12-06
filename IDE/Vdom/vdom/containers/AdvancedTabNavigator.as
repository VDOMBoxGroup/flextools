package vdom.containers {

import mx.containers.TabNavigator;
import mx.core.EdgeMetrics;
import mx.controls.Button;
import mx.styles.StyleManager;
import mx.styles.CSSStyleDeclaration;
import mx.controls.RadioButton;
import mx.events.FlexEvent;

use namespace mx.core.mx_internal;

[Style (name="tabBarPosition", type="String", enumeration="top, bottom", inherit="no")]

public class AdvancedTabNavigator extends TabNavigator {
	
	public static const TOP:String = "top";
	
	public static const BOTTOM:String = "bottom";
	
	public function AdvancedTabNavigator() {
		
		super();
		addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
	}
	
	private function creationCompleteHandler(event:FlexEvent):void {
		
		changeView();
	}
	
	private function changeView():void {
		
		var tabBarPosition:String = getStyle('tabBarPosition');
		
		if(tabBarPosition == TOP) {
			
			setStyle('tabStyleName', 'advancedTabTop');
			
		} else {
			
			setStyle('tabStyleName', 'advancedTabBottom');
		}
	}
	
	override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void {
		
		super.layoutChrome(unscaledWidth, unscaledHeight);
		
		var tabBarPosition:String = getStyle('tabBarPosition');
		
		if (border) {
			
			var borderOffset:Number = tabBarHeight;
			
			border.setActualSize(unscaledWidth, unscaledHeight - borderOffset);
			
			if(tabBarPosition == TOP)
				border.move(0, borderOffset);
			
			else
				border.move(0, 0);
		}
		
		if(tabBar) {
			
			var bm:EdgeMetrics = viewMetrics;
			
			if(tabBarPosition == TOP)
				tabBar.move(bm.left, bm.top);
				
			else
				tabBar.move(bm.left, unscaledHeight - bm.bottom - tabBarHeight - 1);
		}
	}
	
	override protected function get contentY():Number {
		
		var paddingTop:Number = getStyle("paddingTop");
		var tabBarPosition:String = getStyle('tabBarPosition');
		
		if (isNaN(paddingTop))
			paddingTop = 0;
		
		if(tabBarPosition == TOP)			
			return tabBarHeight + paddingTop;
			
		else
			return paddingTop;
    }
    
    private function get tabBarHeight():Number {
    	
		var tabHeight:Number = getStyle("tabHeight");
		
		if (isNaN(tabHeight))
			tabHeight = tabBar.getExplicitOrMeasuredHeight();
		
		return tabHeight - 1;
    }
}
}