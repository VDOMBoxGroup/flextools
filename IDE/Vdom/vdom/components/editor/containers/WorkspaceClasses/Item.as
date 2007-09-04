package vdom.components.editor.containers.WorkspaceClasses {

import flash.display.Graphics;
import mx.core.UIComponent;
import mx.containers.Canvas;
import mx.controls.Label;

public dynamic class Item extends Canvas {
	private var _content:UIComponent;
	private var _objectId:String;
	public var resizeMode:String;
	
	public function Item(id:String) {
		super();
		resizeMode = null;
		horizontalScrollPolicy = "off";
		verticalScrollPolicy = "off";
		focusEnabled = true;
		mouseFocusEnabled = true;
		_objectId = id;
		var lbl:Label = new Label();
		lbl.text = 'ID: ' + id;
		addChild(lbl);
	}
	
	public function get objectId():String {
		
		return _objectId;
	}
	
	public function set objectId(objectId:String):void {
		
		objectId = _objectId;
	}
	
	public function get content():UIComponent {
		
		return _content;
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		var g:Graphics = graphics;
		g.clear();
		g.lineStyle(1);
		g.drawRect(0, 0, unscaledWidth, unscaledHeight);
		g.endFill();
				
		if(!_content) {
			
			_content = new Canvas();
			addChild(_content);
		}
	}
	
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
    	
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		var g:Graphics = graphics;
		g.clear();
		g.lineStyle(1);
		g.drawRect(0, 0, unscaledWidth, unscaledHeight);
		g.endFill();
	}
}
}