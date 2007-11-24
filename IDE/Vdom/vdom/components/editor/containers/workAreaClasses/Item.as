package vdom.components.editor.containers.workAreaClasses {

import mx.containers.Canvas;	

public dynamic class Item extends Canvas {
	
	public var resizeMode:String;
	public var moveMode:Boolean;
	public var contents:String;
	public var guid:String;
	public var containers:String;
	private var _guid:String;
	public var parentId:String;
	
	public function Item(guid:String) {
		super();
		resizeMode = null;
		moveMode = false;
		this.guid = guid;
		horizontalScrollPolicy = "off";
		verticalScrollPolicy = "off";
		focusEnabled = true;
		mouseFocusEnabled = true;
		contents = 'Dynamic';
	}
	
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
    	
		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}
}
}