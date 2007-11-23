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
		
		public function DeleteLineButton()
		{
			bt = new Button();
			bt.height = 18;
			bt.width = 18;
		//	addChild(bt);
			
			icons = new Image();
			icons.source='resource/vdom2_treeEditor_delete_05.png';
			icons.width = 15;
			icons.height = 15;
			icons.x = 2;
			icons.y = 1
			addChild(icons);
			
			visible = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, delButtonOperation);
			addEventListener(MouseEvent.MOUSE_OUT, 	delButtonOperation);
/*	
		*/}
		private function delButtonOperation(msEvt:MouseEvent):void
		{
			if(msEvt.type == MouseEvent.MOUSE_OVER)
				alpha = 1;
			
			if(msEvt.type == MouseEvent.MOUSE_OUT)
				alpha = 0.3;
		}
		
	}
}