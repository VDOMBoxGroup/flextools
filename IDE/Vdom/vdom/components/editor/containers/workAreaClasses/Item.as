package vdom.components.editor.containers.workAreaClasses {

import mx.containers.Canvas;
import flash.display.DisplayObject;	

public dynamic class Item extends Canvas {
	
	public var resizeMode:String;
	public var moveMode:Boolean;
	public var contents:String;
	public var objectID:String;
	public var containers:String;
	private var _guid:String;
	public var parentID:String;
	private var viewArray:Array;
	
	public function Item(objectID:String) {
		
		super();
		
		this.objectID = objectID;
		viewArray = [];
	}
	
	public function addViewChild(child:DisplayObject):void {
		
		viewArray.push(child);
		rawChildren.addChild(child);
	}
	
	public function removeViewChildren():void {
		
		for each (var child:DisplayObject in viewArray) {
			
			rawChildren.removeChild(child);
		}
		
		viewArray = [];
		
	}
}
}