package vdom.containers {
	
import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.controls.Button;
import mx.events.FlexEvent;

public class ControlPanel extends HBox {
	
	private var _buttons:Array;
	private var _selectedItem:Button;
	
	public function ControlPanel():void {
		
		super();
		
		_buttons = new Array();
		addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
	}
	
	override public function addChild(child:DisplayObject):DisplayObject {
		
		super.addChild(child);
		
		if(child is Button) {
			
			child.addEventListener(MouseEvent.CLICK, clickHandler);
			Button(child).toggle = true;
			_buttons.push(child);
		}
					
		return child;
	}
	
	private function creationCompleteHandler(event:FlexEvent):void {
		
		//trace(_buttons.join('\n'));
	}
	
	private function clickHandler(event:MouseEvent):void {
		
		var childIndex:int = _buttons.indexOf(event.currentTarget);
		
		if(_selectedItem)
			_selectedItem.selected = false;
			
		if(childIndex != -1)
			_selectedItem = _buttons[childIndex];
	}
}
}