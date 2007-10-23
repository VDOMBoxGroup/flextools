package vdom.containers {
	
import flash.display.DisplayObject;

import mx.containers.ControlBar;
import mx.containers.Panel;
import mx.controls.Label;
import mx.core.EdgeMetrics;

public class ActionPanel extends Panel {
	
	private var _panelLabel:Label;
	private var _panelName:String;
	private var _panelNameChanged:Boolean;
	
	
	/**
     *  Constructor.
     */
	public function ActionPanel() {
		
		super();
	}
	
	public function get panelName():String {
		
		return _panelName;
	}
	
	public function set panelName(name:String):void {
		
		_panelName = name;
		_panelNameChanged = true;
		invalidateProperties();
	}
	
	override protected function measure():void {
		
		super.measure();
		
		measuredWidth = Math.max(measuredWidth, 100);
		measuredHeight = 105;
	}
	
	override protected function commitProperties():void {
		
		super.commitProperties();

		if (_panelNameChanged) {
			_panelNameChanged = false;
			_panelLabel.text = _panelName;
		}
	}
	
	override protected function createChildren():void {
		
		super.createChildren();
		
		if (!controlBar) {
			
			var tempBar:ControlBar = new ControlBar();
			
			_panelLabel = new Label();
			_panelLabel.percentWidth = 100;
			_panelLabel.height = 16;
			_panelLabel.styleName = 'actionPanlelLabel';
			
			tempBar.addChild(_panelLabel);
			
			controlBar = tempBar;
			
			controlBar.visible = false;
			
			rawChildren.addChild(DisplayObject(controlBar));
		}
	}
	
}
}