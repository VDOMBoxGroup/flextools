package vdom.components.treeEditor
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.core.LayoutContainer;
	import mx.events.DragEvent;
	
	import vdom.events.TreeEditorEvent;
	import flash.display.DisplayObject;
	import mx.states.AddChild;
	import mx.controls.TextArea;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.ui.Mouse;
	
	public class TreeElement extends Canvas
	{
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:TextArea;
		public var ID:String;
		private var rect:Canvas = new Canvas();
		private var min:Boolean = true;
		public var drag:Boolean = true;
		
		public function TreeElement()
		{
			setStyle('backgroundColor', '#99ffff')
			
			
			txt = new Label();
			txt.addEventListener(MouseEvent.MOUSE_DOWN, dispStartDrag);
			txt.buttonMode = true;
			addChild(txt);
			
			btLine = new Button();
			btLine.x  = 80;
			btLine.y  = 3;
			btLine.width = 20;
			btLine.height = 15; 
			btLine.label = 'L';
			addChild(btLine);
			
			btLine.addEventListener(MouseEvent.MOUSE_DOWN, btLineDown);
			btLine.addEventListener(MouseEvent.MOUSE_OUT, btLineOut);
			btLine.addEventListener(MouseEvent.MOUSE_UP, btLineUp);
			
			
			btDelete = new Button();
			btDelete.width = 20;
		 	btDelete.height = 15;
			btDelete.x = 60;
			btDelete.y = 3;
			btDelete.label = 'D';
			btDelete.name = 'deleteButton';
			addChild(btDelete);
			
			btDelete.addEventListener(MouseEvent.MOUSE_DOWN, btDeleteDown);
			btDelete.addEventListener(MouseEvent.MOUSE_UP, btDeleteUp);
			
			
			btLessen = new Button();
			btLessen.width = 20;
		 	btLessen.height = 15;
			btLessen.x = 40;
			btLessen.y = 3;
			btLessen.label = 'H';
			
			btLessen.addEventListener(MouseEvent.MOUSE_DOWN, btLessenDown);
			btLessen.addEventListener(MouseEvent.MOUSE_UP, btLessenUp);
			
			
			addChild(btLessen);
			
			textArea = new TextArea();
			textArea.x = 35; // btButton.width;
			textArea.y = 25  //txt.height;
			textArea.editable = false;
			textArea.selectable = false;
			textArea.text = 'any text, a lot of text';
			textArea.width = 60;
			textArea.height = 40;
			addChild(textArea);
			isRedraw = true;
			addChild(rect);
		}
		
		
		private var isRedraw:Boolean;
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (isRedraw) {
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.REDRAW, ID));
				isRedraw = false;
			}
		}
		
		/**
		 *
		 *  	*******	bt_Line  ******************
		 *  
		 */
		
		private function btLineDown(muEvt:MouseEvent):void
		{
			//this.drag = false;
			//trace('btLineDown');
		}
		
		private function btLineUp(muEvt:MouseEvent):void 
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE, ID));	
		}
		
		
		private function btLineOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
		
		/**
		 *
		 *  	*****	bt_Delete  ************
		 *  
		 */
		
		private function btDeleteDown(muEvt:MouseEvent):void
		{
			this.drag = false;
			trace('btDeleteDown');
		}
		
		private function btDeleteUp(muEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, ID));	
		}

		private function btDeleteOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
		
		/**
		 *
		 *  	*********	bt_Lessen ******************
		 *  
		 */
		
		private function btLessenDown(muEvt:MouseEvent):void
		{
			this.drag = false;
			trace('btLessenDown');
		}
		// при нажатии кнопки свернуть
		private function btLessenUp(msEnt:MouseEvent):void
		{
			trace('btLessenUp');
			// убираем "лишнее"
			if (min){
				removeChild(textArea);
				min = false;
			}else{
				addChild(textArea);
				min = true;
			}
			//	убираем квадрат
			rect.graphics.clear();
			
			isRedraw = true;
		}
		
		private function btLessenOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
	
		
		override public function set name(names:String):void
		{
			txt.text = names;
			ID = names;
		}
		
		
		public function set current(data:Boolean):void
		{
			if (data){
				drawRect();
			} else {
				rect.graphics.clear();
			}
		}
		
		private function dispStartDrag(evt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAG, ID));
		}
		 
		private function dispStopDrag(evt:MouseEvent):void
		{
		//	dispatchEvent(new TreeEditorEvent(TreeEditorEvent.STOP_DRAG, ID));
		}
		 
		private function drawRect():void
		{
			rect.graphics.lineStyle(1, 1, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			rect.graphics.drawRect(0, 0, this.width, this.height);
		}
		
	
	}
}