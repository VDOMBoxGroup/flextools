package vdom.components.edit.containers.typeAccordionClasses{

import flash.events.MouseEvent;
import flash.utils.ByteArray;

import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.core.DragSource;

import vdom.managers.VdomDragManager;

public class Type extends VBox {
	
	private var typeId:String;
	
	private var typeIcon:Image;
	private var _typeLabel:Label;
	private var _typeLabelText:String;
	
	private var aviableContainers:String;
	
	public function Type(value:Object) {
		
		super();
		
		addEventListener(MouseEvent.MOUSE_DOWN, dragIt);
		
		typeId = value.typeId;
		aviableContainers = value.aviableContainers;
	}
	
	public function set resource(imageResource:ByteArray):void {
		
		typeIcon.source = imageResource;
		visible = true;
	}
	
	public function set typeLabel(value:String):void {
		
		_typeLabelText = value;
	}
	
	private function dragIt(event:MouseEvent):void {
		
		var dragInitiator:Type = Type(event.currentTarget);
		var ds:DragSource = new DragSource();
		
		var dataObject:Object = {
			typeId:typeId, 
			aviableContainers:aviableContainers, 
			offX:dragInitiator.mouseX, 
			offY:dragInitiator.mouseY
		};
		
		ds.addData(dataObject, 'typeDescription');
		
		var proxy:Image = new Image();
		
		proxy.width = 58;
		proxy.height = 58;
		proxy.source = typeIcon.source;
		
		VdomDragManager.doDrag(
			dragInitiator, 
			ds, 
			event, 
			proxy, 
			proxy.width/2 - dragInitiator.mouseX, 
			proxy.height/2 - dragInitiator.mouseY
		);
		
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!typeIcon) {
			
			typeIcon = new Image();
			
			typeIcon.width = 58;
			typeIcon.height = 58;
			typeIcon.setStyle('backgroundColor', '#FF00FF');
			
			addChild(typeIcon);
		}
		if(!_typeLabel) {
			
			_typeLabel = new Label();
			
			_typeLabel.truncateToFit = true;
			_typeLabel.width = 90;
			
			addChild(_typeLabel);
		}
	}
	
	override protected function commitProperties():void {
		
		super.commitProperties();
		
		if(_typeLabel && _typeLabel.text != _typeLabelText)
			_typeLabel.text = _typeLabelText;
	}
}
}