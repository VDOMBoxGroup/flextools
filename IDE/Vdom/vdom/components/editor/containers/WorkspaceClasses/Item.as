package vdom.components.editor.containers.WorkspaceClasses
{
import mx.containers.Canvas;
import mx.core.UIComponent;
import mx.controls.Label;
import flash.display.Graphics;
	
public dynamic class Item extends Canvas
{
	private var _content:UIComponent;
	private var _objectId:String;
	
	public function Item(id:String)
	{
		super();
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
		//g.beginFill(0xFF00FF, 1);
		g.lineStyle(1);
		g.drawRect(0, 0, unscaledWidth, unscaledHeight);
		g.endFill();
		//var s:Image = new Image;
		//s.source = border;
		
		if(!_content) {
			_content = new Canvas();
			//var txt:TextArea = TextArea(_content);
			//txt.focusEnabled = false;
			//txt.mouseFocusEnabled = true;
			//txt.text = _objectId.toString();
			//txt.percentWidth = 100;
			//txt.height = txt.measuredHeight;
			//txt.text = 'zzz';
			//txt.focusEnabled = true;
			//txt.mouseFocusEnabled = true;
			//txt.setStyle('focusAlpha', '0');
			//txt.setStyle('focusThickness', '0');
			addChild(_content);
		}
	}
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		var g:Graphics = graphics;
		g.clear();
		//g.beginFill(0xFF00FF, 1);
		g.lineStyle(1);
		g.drawRect(0, 0, unscaledWidth, unscaledHeight);
		g.endFill();
		//setStyle('backgroundColor', '#ff0000');
		//setStyle('borderStyle', 'solid');
		//setStyle('borderThickness', '1');
		//setStyle('borderColor', '#000000');
	}
}
}