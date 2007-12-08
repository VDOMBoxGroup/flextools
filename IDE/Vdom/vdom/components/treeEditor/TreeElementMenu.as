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
		private var canMenu:Canvas  = new Canvas();
		private var canRect:Canvas = new Canvas();
		private var delta:Number = 0;
		
		
		public function TreeElementMenu():void
		{
			var btWidth:int = 18;
			var btHeight:int = 18;
			
			
			btLessen = new Button();
			btLessen.width = btWidth;
		 	btLessen.height = btHeight;
			btLessen.x = 0;
			btLessen.y = 3;
			
			imgLessen = new Image();
			imgLessen.source = 'assets/TreeEditor/vdom2_treeEditor_show_on_02.png';
			imgLessen.width = btLessen.width - 3;
			imgLessen.height = btLessen.height - 3;
			imgLessen.x = btLessen.x + 2 ;
			imgLessen.y = btLessen.y + 1;
			imgLessen.buttonMode = true;
			imgLessen.addEventListener(MouseEvent.CLICK, imgLessenClick);
			canMenu.addChild(imgLessen);
			
			// кнопка удалить
			
			btDelete = new Button();
			btDelete.width = btWidth;
		 	btDelete.height = btHeight;
			btDelete.x = 40;
			btDelete.y = 3;
			btDelete.name = 'deleteButton';

			imgDelete = new Image();
			imgDelete.source='assets/TreeEditor/vdom2_treeEditor_delete_05.png';
			imgDelete.width = btDelete.width - 3;
			imgDelete.height = btDelete.height - 3;
			imgDelete.x = btDelete.x + 2 ;
			imgDelete.y = btDelete.y + 1;
			imgDelete.buttonMode = true;
			imgDelete.addEventListener(MouseEvent.CLICK, imgDeleteClick);
			canMenu.addChild(imgDelete);
			
			// кнопка линия
			btLine = new Button();
			btLine.x  = 20;
			btLine.y  = 3;
			btLine.width = btWidth;
			btLine.height = btHeight; 
		
		
		
			imgLine = new Image();
			imgLine.source='assets/TreeEditor/vdom2_treeEditor_line_02.png';
			imgLine.width = btLine.width - 3;
			imgLine.height = btLine.height - 3;
			imgLine.x = btLine.x + 2 ;
			imgLine.y = btLine.y + 1;
			imgLine.buttonMode = true;
			imgLine.addEventListener(MouseEvent.CLICK, imgLineClick); 
			
			canMenu.addChild(imgLine);
			addChild(canMenu);
			addChild(canRect);
			
			canMenu.alpha = 0;
		}
		
		public function alfaMenu(deltaX:Number, deltaY:Number):void
		{
			if(	deltaX < this.width && deltaX > 0
				&& deltaY < 25 && deltaY > 0)
			 {
			 	canMenu.alpha = 1;	
			 	return
			 }
			deltaX = Math.abs(deltaX)- this.width/2 ;
			deltaY = Math.abs(deltaY) - 10; 
			
			delta = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
			canMenu.alpha = (100 - Math.abs(delta))/100;
				
		} 
		public function set position(objPosit:Object):void
		{
			this.visible = true;
			
			this.x = objPosit.x;
			this.y = objPosit.y-25;
			if (!objPosit.width)return;
			
			
			canRect.graphics.clear();
			canRect.graphics.lineStyle(3, 0xdd1000, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.beginFill(0x555555,  0);
	//		graphics.drawRect(0, 0, evt.currentTarget.width, evt.currentTarget.height);
		
			canRect.graphics.drawRect(-1, 23, objPosit.width+2, objPosit.height+2);
			canMenu.alpha = .9;
		}
		
		
		private function stopImmediateProp(msEvt:MouseEvent):void
		{
			msEvt.stopPropagation();
		}
		
		
		
		public function set setAlpha(alf:Number):void
		{
			
				//canRect.alpha = alf;
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
		
		private function canMenuAlpha(msEvt:MouseEvent):void
		{
			canMenu.alpha = 1;
		}
	}
}