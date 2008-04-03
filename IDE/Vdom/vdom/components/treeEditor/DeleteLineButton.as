package vdom.components.treeEditor
{
	import mx.controls.Button;
	import mx.styles.StyleManager;
	import mx.states.SetStyle;
	import mx.controls.Image;
	import mx.containers.Canvas;
	import flash.events.MouseEvent;

	public class DeleteLineButton extends Canvas
	{
		private var icons:Image;
		private var bt:Button;
		
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='deleteLine')]
			[Bindable]
		public var deleteLine:Class;
		
		public function DeleteLineButton()
		{
			super();
			
			icons = new Image();
			icons.maintainAspectRatio = false;
			icons.scaleContent = true;
			
			icons.source = deleteLine;
			icons.width = 18;
			icons.height = 18;
			icons.x = 2;
			icons.y = 1
			addChild(icons);
			//this.height = 35;
		//	this.width = 35;
			visible = false;
			
			//addEventListener(MouseEvent.MOUSE_OVER, delButtonOperation);
			//addEventListener(MouseEvent.MOUSE_OUT, 	delButtonOperation);
/*	
		*/}
		private function delButtonOperation(msEvt:MouseEvent):void
		{
			if(msEvt.type == MouseEvent.MOUSE_OVER)
				alpha = 1;
			
			if(msEvt.type == MouseEvent.MOUSE_OUT)
				alpha = 0.5;
		}
		
	}
}