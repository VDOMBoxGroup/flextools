package vdom.containers {

import flash.display.Graphics;

import mx.containers.Canvas;
import mx.core.UIComponent;

import vdom.managers.renderClasses.WaitCanvas;	

public class Item extends Canvas implements IItem {
	
	private var _objectId:String;
	private var _waitMode:Boolean;
	private var _highlightMarker:Canvas;
	private var _isStatic:Boolean;
	private var _editableAttributes:Array;
	
	public function Item(objectId:String) {
		
		super();
		
		_objectId = objectId;
		editableAttributes = [];
		_isStatic = false;
	}
	
	public function get objectId():String {
		
		return _objectId;
	}
	
	public function get waitMode():Boolean {
		
		return _waitMode;
	}
	
	public function set waitMode(mode:Boolean):void {
		
		if(mode) {
			
			var waitLayout:UIComponent = new WaitCanvas();
			
			addChild(waitLayout);
			
		}
	}
	
	public function get editableAttributes():Array {
		
		return _editableAttributes;
	}
	
	public function set editableAttributes(attributesArray:Array):void {
		
		_editableAttributes = attributesArray;
	}
	
	public function get isStatic():Boolean {
		
		return _isStatic;
	}
	
	public function set isStatic(flag:Boolean):void {
		
		_isStatic = flag;
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!_highlightMarker)
			_highlightMarker = new Canvas();
		
		_highlightMarker.visible = false;
		
		rawChildren.addChild(_highlightMarker);
	}
	
	public function drawHighlight(color:String):void {
		
		if(color && color == 'none') {
			
			_highlightMarker.visible = false;
			return;
		}
			
		var graph:Graphics = _highlightMarker.graphics;
		
		graph.clear()
		graph.lineStyle(2, Number(color));
		graph.drawRect(0, 0, width, height);
		
		bringOnTop();
		
		_highlightMarker.visible = true;
	}
	
	private function bringOnTop():void {
		
		var highlightMarkerIndex:int = rawChildren.getChildIndex(_highlightMarker);
		var topIndex:int = rawChildren.numChildren-1;
		
		if(highlightMarkerIndex != topIndex) {
			rawChildren.setChildIndex(_highlightMarker, topIndex);
		}
	}
}
}