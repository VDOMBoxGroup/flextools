package vdom.utils {
	
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.utils.getDefinitionByName;

import mx.core.Application;

public class DisplayUtil {
	
	public static function getObjectsUnderMouse(
			rootContainer:DisplayObjectContainer, 
			targetClassName:String, 
			filterFunction:Function = null):Array {
		
		var app:Application = Application.application as Application;
	
		var allObjectUnderPoint:Array = app.stage.getObjectsUnderPoint( 
				new Point(app.stage.mouseX, app.stage.mouseY )
		);
		
		var stack:Array = new Array();
		
		var targetClass:Class = getDefinitionByName(targetClassName) as Class;
		
		for (var i:int = allObjectUnderPoint.length-1; i >= 0; i--) {
			
			var target:DisplayObject = allObjectUnderPoint[i];
				
			while (target is DisplayObject) {
					
				if(target is targetClass)
					break;
				
				if(target.hasOwnProperty('parent'))
					target = target.parent;
									
				else
					target = null;
			}
			
			if (target && stack[stack.length - 1] != target) {
			
				var check:Boolean = true;
				
				if(filterFunction != null)
					check = filterFunction(target);
				
				if(check)
					stack.push(target);
			}
		}
		
		return stack;
	}	
}
}