package vdom.components.treeEditor
{
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import flash.events.MouseEvent;
	import vdom.events.TreeEditorEvent;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;

	public class TreeElementMenu extends Canvas
	{
		private var btLessen:Button;
		private var btDelete:Button;
		private var btLine:Button;
		
		private var imgDelete:Image;
		private var imgLine:Image;
		private var imgLessen:Image;
		
		
		public function TreeElementMenu():void
		{
			var btWidth:int = 18;
			var btHeight:int = 18;
			
			btLessen = new Button();
			btLessen.width = btWidth;
		 	btLessen.height = btHeight;
			btLessen.x = 40;
			btLessen.y = 3;
	//		btLessen.label = 'H';
	//		btLessen.addEventListener(MouseEvent.MOUSE_OUT, stopImmediateProp);
			btLessen.addEventListener(MouseEvent.CLICK, btLessenClick);
//			addChild(btLessen);
			
			imgLessen = new Image();
			imgLessen.source = 'resource/vdom2_treeEditor_show_on_02.png';
			imgLessen.width = btLessen.width - 3;
			imgLessen.height = btLessen.height - 3;
			imgLessen.x = btLessen.x + 2 ;
			imgLessen.y = btLessen.y + 1;
			imgLessen.buttonMode = true;
			imgLessen.addEventListener(MouseEvent.CLICK, imgLessenClick);
			addChild(imgLessen);
			
			// кнопка удалить
			
			btDelete = new Button();
			btDelete.width = btWidth;
		 	btDelete.height = btHeight;
			btDelete.x = 80;
			btDelete.y = 3;
		//	btDelete.label = 'D';
			btDelete.name = 'deleteButton';
	//		addChild(btDelete);

			imgDelete = new Image();
			imgDelete.source='resource/vdom2_treeEditor_delete_05.png';
			imgDelete.width = btDelete.width - 3;
			imgDelete.height = btDelete.height - 3;
			imgDelete.x = btDelete.x + 2 ;
			imgDelete.y = btDelete.y + 1;
			imgDelete.buttonMode = true;
			imgDelete.addEventListener(MouseEvent.CLICK, imgDeleteClick);
			addChild(imgDelete);
		//	btDelete.addEventListener(MouseEvent.MOUSE_OUT, stopImmediateProp);
			
			// кнопка линия
			btLine = new Button();
			btLine.x  = 60;
			btLine.y  = 3;
			btLine.width = btWidth;
			btLine.height = btHeight; 
		//	btLine.label = 'L';
//			addChild(btLine);
		//	btLine.addEventListener(MouseEvent.CLICK, btLineClick);
		
		
			imgLine = new Image();
			imgLine.source='resource/vdom2_treeEditor_line_02.png';
			imgLine.width = btLine.width - 3;
			imgLine.height = btLine.height - 3;
			imgLine.x = btLine.x + 2 ;
			imgLine.y = btLine.y + 1;
			imgLine.buttonMode = true;
			imgLine.addEventListener(MouseEvent.CLICK, imgLineClick); 
			
			addChild(imgLine);
		
			alpha = 0.1;
		}
		
		public function set position(objPosit:Object):void
		{
			this.visible = true;
			
			this.x = objPosit.x;
			this.y = objPosit.y-25;
			trace(objPosit.width);
			if (!objPosit.width)return;
			
			graphics.clear();
			graphics.lineStyle(3, 0.5, 0.5, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		//	graphics.beginFill(0x555555,  0);
		//	graphics.drawRect(0, 0, evt.currentTarget.width, evt.currentTarget.height);
			graphics.drawRect(-1, 23, objPosit.width+1, objPosit.height+1);
		}
		
		
		private function stopImmediateProp(msEvt:MouseEvent):void
		{
			msEvt.stopPropagation();
		}
		
		public function set show(sh:Boolean):void
		{
			
		}
		
		private function setAlpha():void
		{
			
		}
		
		private function btLessenClick(msEvt:MouseEvent):void
		{
			//dispatchEvent(new TreeEditorEvent(TreeEditorEvent.));
		}
		
		private function imgLessenClick(msEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.RESIZE_TREE_ELEMENT));
		}
		
		private function imgDeleteClick(msEvt:MouseEvent):void
		{
			this.visible = false;
			
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE))
		}
		
		private function imgLineClick(msEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE))
		}
	}
}