package vdom.components.treeEditor
{
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	
	import mx.containers.Canvas;
	import mx.containers.TitleWindow;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.events.DragEvent;
	import mx.states.AddChild;
	import mx.states.SetStyle;
	
	import vdom.events.TreeEditorEvent;
	
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
			super();
			setStyle('backgroundColor', '#99ffff')
		//	setStyle('borderColor', '#ff0000')
			//setStyle('borderStyle', 'solid')
		//	this.setStyle('cornerRadius','15px') 
		//	setStyle('borderThickness', '5px'); 
		//	initHead();
			
			initLittleBody();
			initBigBody(); 
			
			isRedraw = true;
			addChild(rect);
			this.buttonMode = true;
		}
		
		
		private function initLittleBody():void
		{
			txt = new Label();
		//	txt.addEventListener(MouseEvent.MOUSE_DOWN, dispStartDrag);
			txt.buttonMode = true;
			addChild(txt);
		}
		
		private function initBigBody():void
		{
			textArea = new TextArea();
			textArea.x = 35; // btButton.width;
			textArea.y = 25  //txt.height;
			textArea.editable = false;
	//		textArea.selectable = false;
			textArea.text = 'any text, a lot of text';
			textArea.width = 60;
			textArea.height = 40;
			addChild(textArea);
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
		
		
		
		private function btLineClick(muEvt:MouseEvent):void 
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
		}
		
		private function btDeleteClick(muEvt:MouseEvent):void
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
		}
		// при нажатии кнопки свернуть
		public function set resize(blHide:Boolean):void
		{
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
			if (data)
				drawRect();
			else 
				rect.graphics.clear();
		}
		
		private function dispStartDrag(evt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAG, ID));
		}
		 
		
		 
		private function drawRect():void
		{
			rect.graphics.lineStyle(1, 1, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			rect.graphics.drawRect(0, 0, this.width, this.height);
		}
		
	
	}
}