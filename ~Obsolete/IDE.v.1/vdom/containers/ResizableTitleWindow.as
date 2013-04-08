package vdom.containers {

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.containers.TitleWindow;
import mx.core.EdgeMetrics;

public class ResizableTitleWindow extends TitleWindow {
	
	private const buttonColor:Number = 0x000000;
	private const buttonInactiveColor:Number = 0x666666;

	protected var resizeButton:Sprite;
	
	public function ResizableTitleWindow() {
		
		super();
	}
	
	protected override function createChildren():void{
		super.createChildren();			
		
		resizeButton = new Sprite();
		titleBar.addChild(resizeButton);
			
		//Reactivate handcursor			 
		resizeButton.useHandCursor = true;
		resizeButton.buttonMode = true;
		
		//Draw the buttons
		drawResizeButton(true);
								
		//Add handlers	 
		resizeButton.addEventListener(MouseEvent.MOUSE_DOWN, resizeDownHandler);	
	}
	
	override protected function layoutChrome(unscaledWidth:Number,
											 unscaledHeight:Number):void {
											 	
		super.layoutChrome(unscaledWidth, unscaledHeight);
		
		var bm:EdgeMetrics = borderMetrics;
		
		var x:Number = bm.left;
		var y:Number = bm.top;
		
		var headerHeight:Number = getHeaderHeight();
		
		resizeButton.x = unscaledWidth - x - bm.right + 10;
		resizeButton.y = unscaledHeight - resizeButton.height + 1;
	}
	
	private function resizeDownHandler(event:MouseEvent):void{
		
		event.stopImmediatePropagation();
		
		resizeButton.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
						
		systemManager.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		systemManager.addEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
	}
						
	private function resizeUpHandler(event:MouseEvent):void{
		
		event.stopImmediatePropagation();
		
		resizeButton.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
		
		systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		systemManager.removeEventListener(MouseEvent.MOUSE_UP, resizeUpHandler);
	}
			
	private function mouseMoveHandler(event:MouseEvent):void{
					  
		var stagePoint:Point = new Point(event.stageX, event.stageY);
		
		var parentPoint:Point = parent.globalToLocal(stagePoint);
		
		var newWidth:Number = stagePoint.x - x;
		var newHeight:Number = stagePoint.y - y;
		var bm:EdgeMetrics = viewMetrics;
		
		var minWidth:Number = titleTextField.textWidth 
								+ bm.left*2 + bm.right*2;
						
		if(newWidth + x < parent.width){
			newWidth = stagePoint.x - x;
		}else{
			newWidth = parent.width - x;
		}
		
		if(newHeight + y < parent.height){
			newHeight = stagePoint.y - y;  
		}else{
			newHeight = parent.height - y;
		}	
		
		if(newWidth < minWidth)
			newWidth = minWidth;
		
		if(newWidth < bm.left + bm.right)
			newWidth = bm.left + bm.right;
					  
		if(newHeight < bm.top + bm.bottom)
			newHeight = bm.top + bm.bottom;
		
		width = newWidth;
		height = newHeight;
	}
			
			
	private function drawResizeButton(active:Boolean):void{
		
		var col:Number;
		
		if(active == true){
			col = buttonColor;
		}else{
			col = buttonInactiveColor;
		}					
		
		var g:Graphics = resizeButton.graphics;
		
		g.clear();				
		g.lineStyle(1, col);
		g.moveTo(0,10);
		g.lineTo(10,0);
		g.moveTo(6,10);
		g.lineTo(10,6);
		g.moveTo(3,10);
		g.lineTo(10,3);
		
		g.lineStyle();
		g.beginFill(0xFFFFFF, 0.01);
		g.drawRect(0,0,10,10);
	}
}
}