package vdom.components.treeEditor.colormenu
{
	import mx.containers.Canvas;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import mx.controls.Image;
	import flash.events.MouseEvent;
	import mx.charts.BubbleChart;
	import flash.events.Event;
	import vdom.events.TreeEditorEvent;
	

	public class ColorMenuPicture extends Canvas
	{
		public var level:String = '';
		
		private var color:Number;
		private var imgShow:Image;
		private var imgHide:Image;
		private var imageWidth:int = 18;
		private var imageheight:int = 18;
		
		public function ColorMenuPicture(obg:Object)
		{
			super();
			this.level = obg.level;
			this.color = obg.data;
			graphics.lineStyle(3, color, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.beginFill(0x555555,  0);
			graphics.drawRect(0, 0, 20, 20);
			this.buttonMode = true;
			//trace(this.level);
			createImage();
			
			addEventListener(MouseEvent.CLICK, showPictureHandler);
		}
		
		private function createImage():void
		{
				imgShow = new Image();
				imgHide = new Image();
				
				imgShow.source =  'assets/TreeEditor/are.png';
				imgHide.source =  'assets/TreeEditor/are02.png';
				
				imgShow.x = 1;
				imgHide.x = 1;
				
				imgShow.y = 1;
				imgHide.y = 1;
				
				imgShow.width = imageWidth;
				imgHide.width = imageWidth;
				
				imgShow.height = imageheight;
				imgHide.height = imageheight;
				
				imgHide.visible = false;
				
				addChild(imgShow);
				addChild(imgHide);
		}
		
		private function showPictureHandler(msEvt:MouseEvent):void
		{
			if (imgShow.visible)
			{
				imgHide.visible = true;
				imgShow.visible = false;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.HIDE_LINES, level));
			}
			else
			{
				imgHide.visible = false;
				imgShow.visible = true;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SHOW_LINES, level));
			}
		}
	}
}