package vdom.components.editor.containers.workAreaClasses {

import mx.containers.Canvas;
import flash.display.DisplayObject;
import mx.core.UIComponent;
import flash.display.Graphics;
import vdom.managers.renderClasses.WaitCanvas;
import mx.controls.Button;
Button


public dynamic class Item extends Canvas {
	
	public var resizeMode:String;
	public var moveMode:Boolean;
	public var contents:String;
	public var objectID:String;
	//public var containers:String;
	public var isStatic:Boolean;
	
	private var _guid:String;
	public var parentID:String;
	public var editableAttributes:Array;
	private var viewArray:Array;
	private var _waitMode:Boolean;
	
	private var _highlightMarker:Canvas;
	
	public function Item(objectID:String) {
		
		super();
		
		this.objectID = objectID;
		editableAttributes = [];
		viewArray = [];
		isStatic = false;
	}
	
	public function get waitMode():Boolean {
		
		return _waitMode;
	}
	
	public function set waitMode(mode:Boolean):void {
		
		if(mode) {
			
			var waitLayout:UIComponent = new WaitCanvas;
			
			addChild(waitLayout);
			
		}
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if(!_highlightMarker)
			_highlightMarker = new Canvas();
		
		_highlightMarker.visible = false;
		
		rawChildren.addChild(_highlightMarker);
	}
	
	/* public function get highlight():Boolean {
		
		return _highlightMarker.visible;
	} */
	
	public function highlight(flag:Boolean):void {
		
		if(_highlightMarker.visible == flag)
			return
		
		if(flag) {
			
			var graph:Graphics = _highlightMarker.graphics;
			
			graph.clear()
			graph.lineStyle(2, 0x666666);
			graph.drawRect(0, 0, width, height);
			
			bringOnTop();
			
			_highlightMarker.visible = true;
			
		} else {
			_highlightMarker.visible = false;;
		}
	}
	
	private function bringOnTop():void {
		
		var highlightMarkerIndex:int = rawChildren.getChildIndex(_highlightMarker);
		var topIndex:int = rawChildren.numChildren-1;
		
		if(highlightMarkerIndex != topIndex) {
			rawChildren.setChildIndex(_highlightMarker, topIndex);
		}
	}
	
	
	
	/* public function addViewChild(child:DisplayObject):void {
		
		viewArray.push(child);
		addChild(child);
	} */
	
	/* override public function removeAllChildren():void {
		
		var itemIndex:uint = 1;
		
		_highlightMarker.visible = false;
		
		bringOnTop();
		
		while (numChildren > itemIndex) {
			
			removeChildAt(0);
		} */
		
		//var myNum1Children:* = numChildren;
		//var myNum2Children:* = rawChildren.numChildren;
		//trace('numChildren: ' + numChildren);
	//}
	
	/* public function removeViewChildren():void {
		
		for each (var child:DisplayObject in viewArray) {
			
			removeChild(child);
		}
		
		viewArray = [];
		
	} */
}
}