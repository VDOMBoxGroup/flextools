package vdom.components.editor.containers.workAreaClasses {

import mx.containers.Canvas;	

public dynamic class Item extends Canvas {
	
	public var resizeMode:String;
	public var moveMode:Boolean;
	public var contents:String;
	public var objectID:String;
	public var containers:String;
	private var _guid:String;
	public var parentID:String;
	
	public function Item(objectID:String) {
		
		super();
		
		this.objectID = objectID;
	}
}
}