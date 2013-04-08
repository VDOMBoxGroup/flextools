package vdom.components.treeEditor
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;

	public class DeleteLineButton extends Canvas
	{
		private var icons:Image;
		private var iconsBig:Image;
		private var bt:Button;
		
		
		[Embed(source='/assets/treeEditor/test/delete_small.png')]
			[Bindable]
		public var deleteLine:Class;
		
		[Embed(source='/assets/treeEditor/test/delete_big.png')]
			[Bindable]
		public var deleteLine_big:Class;
		
		public function DeleteLineButton()
		{
			super();
			buttonMode = true;
			icons = new Image();
			icons.maintainAspectRatio = false;
			icons.scaleContent = true;
			
			icons.source = deleteLine;
//			icons.width = 18;
//			icons.height = 18;
			icons.x = 5;
			icons.y = 5
			addChild(icons);
			
			iconsBig = new Image();
			iconsBig.source = deleteLine_big; 
			addChild(iconsBig);		
			
			visible = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseHandler);
			addEventListener(MouseEvent.CLICK, mouseHandler);
		}
		
		private function mouseHandler(msEvt:MouseEvent):void
		{
			if(msEvt.type == MouseEvent.MOUSE_OVER)
			{
				iconsBig.visible = true;
			}else
			{
				iconsBig.visible = false;
			}
		}
	}
}