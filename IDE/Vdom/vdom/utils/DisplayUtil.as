package vdom.utils {
	
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.utils.getQualifiedClassName;

import mx.core.Application;

public class DisplayUtil {
	
	public static function getObjectsUnderMouse(
			rootContainer:DisplayObjectContainer, 
			targetClassName:String):Array {
		
		var app:Application = Application.application as Application;
	
		var allObjectUnderPoint:Array = app.stage.getObjectsUnderPoint( 
				new Point(app.stage.mouseX, app.stage.mouseY )
		);
			
		var stack:Array = new Array();
		
		for (var i:int = allObjectUnderPoint.length-1; i >= 0; i--) {
			
			var target:DisplayObject = allObjectUnderPoint[i];
			
			if (!rootContainer.contains(target))
				continue
			
			while (target) {
				
				var currentClassName:String = getQualifiedClassName(target);
					
				if(currentClassName == targetClassName)
					break;
					
				if(target.hasOwnProperty('parent'))
					target = target.parent;
									
				else
					target = null;
			}
			
			if (target && stack[stack.length - 1] != target)
				stack.push(target);
		}
		
		return stack;
	}
	
}
}