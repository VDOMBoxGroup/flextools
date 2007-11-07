package vdom.components.treeEditor
{
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import flash.events.MouseEvent;

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
			btLessen.addEventListener(MouseEvent.MOUSE_OUT, stopImmediateProp);
//			addChild(btLessen);
			
			imgLessen = new Image();
			imgLessen.source = 'resource/vdom2_treeEditor_show_on_02.png';
			imgLessen.width = btLessen.width - 3;
			imgLessen.height = btLessen.height - 3;
			imgLessen.x = btLessen.x + 2 ;
			imgLessen.y = btLessen.y + 1;
			imgLessen.buttonMode = true;
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
			addChild(imgDelete);
			btDelete.addEventListener(MouseEvent.MOUSE_OUT, stopImmediateProp);
			
			// кнопка линия
			btLine = new Button();
			btLine.x  = 60;
			btLine.y  = 3;
			btLine.width = btWidth;
			btLine.height = btHeight; 
		//	btLine.label = 'L';
//			addChild(btLine);
			btLine.addEventListener(MouseEvent.MOUSE_OUT, stopImmediateProp);
		
		
			imgLine = new Image();
			imgLine.source='resource/vdom2_treeEditor_line_02.png';
			imgLine.width = btLine.width - 3;
			imgLine.height = btLine.height - 3;
			imgLine.x = btLine.x + 2 ;
			imgLine.y = btLine.y + 1;
			imgLine.buttonMode = true;
			
			
			addChild(imgLine);
		
			alpha = 0.1;
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
	}
}