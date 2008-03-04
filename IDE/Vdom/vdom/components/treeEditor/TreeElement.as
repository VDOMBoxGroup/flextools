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
	import mx.controls.Image;
	import vdom.connection.utils.Extract;
	import vdom.connection.utils.UtilsEvent;
	import mx.controls.TextInput;
	import flash.events.KeyboardEvent;
	
	public class TreeElement extends Canvas
	{
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:TextArea;
		public var _ID:String;
//		private var rect:Canvas = new Canvas();
		private var min:Boolean = false;
		public var drag:Boolean = true;
		private var image:Image;
		private var imgBackGround:Image;
		private var imgPlus:Image;
		private var imgheader:Image;
		private var cnvUpLayer	:Canvas = new Canvas();
		private var cnvDownLayer:Canvas = new Canvas();		
		private var txtInp:TextInput;
		private var _type:Label;
		
		
		
		public var _resourceID:String = '';
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='defaultPicture')]
		[Bindable]
		public var defaultPicture:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='backGround')]
		[Bindable]
		public var backGround:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='header')]
		[Bindable]
		public var header:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='plus')]
		[Bindable]
		public var plus:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='minus')]
		[Bindable]
		public var minus:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='line')]
		[Bindable]
		public var line:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='delete')]
		[Bindable]
		public var delet:Class;
		
		
		
		public function TreeElement()
		{
			super();

			initUpBody();
			initDownBody(); 
			
			isRedraw = true;
			this.buttonMode = true;
			addEventListener(MouseEvent.CLICK, endFormatinfHandler)
		}
		
		
		private function initUpBody():void
		{
			imgheader = new Image();
			imgheader.source = header;
			
			txt = new Label();
			txt.setStyle('color', '#ffffff');
			txt.setStyle('fontWeight', "bold"); 
			txt.setStyle('textAlign', 'center');
			
			txt.y = 20;
			txt.width =  240;
			txt.buttonMode = true;
			txt.doubleClickEnabled = true;
			txt.addEventListener(MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler)
			
			var imgLine:Image = new Image();
			imgLine.source = line;
			imgLine.y = 2;
			imgLine.x = 20;	
			imgLine.addEventListener(MouseEvent.CLICK, lineClickHandler);
			
			var imgDelete:Image = new Image();
			imgDelete.source = delet;
			imgDelete.y = 2;
			imgDelete.x = 40;	
			imgDelete.addEventListener(MouseEvent.CLICK, deleteClickHandler);
			
			imgPlus = new Image();
			imgPlus.source = plus;
			imgPlus.y = 2;
			imgPlus.x = 4;	
			imgPlus.addEventListener(MouseEvent.CLICK, plusClickHandler);	
			
			txtInp = new TextInput();
			txtInp.setStyle('borderColor', '#000000');
			txtInp.setStyle('fontWeight', "bold"); 
			txtInp.setStyle('textAlign', 'center');
			txtInp.y = 20;
			txtInp.width =  240;
			txtInp.visible = false;
			
			cnvUpLayer.addChild(imgheader);
			cnvUpLayer.addChild(txt);
			cnvUpLayer.addChild(imgPlus);
			cnvUpLayer.addChild(txtInp);
			cnvUpLayer.addChild(imgLine);
			cnvUpLayer.addChild(imgDelete);
			
			addChild(cnvUpLayer);
			
		}
		
		private function initDownBody():void
		{
			imgBackGround = new Image();
			imgBackGround.source = backGround;
			imgBackGround.y = 27;
			cnvDownLayer.addChild(imgBackGround);
			
			textArea = new TextArea();
			textArea.setStyle('fontWeight', "bold"); 
			textArea.x = 115; // btButton.width;
			textArea.y = 35  //txt.height;
			textArea.editable = false;
			textArea.focusEnabled = true;
			textArea.text = 'press double click for edit this text';
			textArea.width =  125;
			textArea.height = 75;
			textArea.doubleClickEnabled = true;
			textArea.addEventListener(MouseEvent.DOUBLE_CLICK, textAreaDoubleClickHandler);
			cnvDownLayer.addChild(textArea);
			
			image = new Image();
			image.source = defaultPicture;
			image.y = 5;
			image.height = 80;
			cnvDownLayer.addChild(image);
			
			
			
			cnvDownLayer.y = 15;
			
			
			_type = new Label();
			_type.text = 'text  ';
			_type.y = 120;
			_type.x = 120;
			_type.width =  100;
			_type.setStyle('fontSize', "8");
			_type.setStyle('fontWeight', "bold"); 
			cnvDownLayer.addChild(_type);
			
			
		}
		
		private var isRedraw:Boolean;
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (isRedraw) {
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.REDRAW, _ID));
				isRedraw = false;
			}
		}
		
		private function plusClickHandler(msEvt:MouseEvent):void
		{
			if (min){
				removeChild(cnvDownLayer);
				imgPlus.source = plus;
				
				min = false;
			}else{
				addChild(cnvDownLayer);
				imgPlus.source = minus;
				
				min = true;
			}	
			isRedraw = true;
		}
		
		
		
		private function txtDoubleClickHandler(msEvt:MouseEvent):void
		{
			txtInp.visible = true;
			txtInp.text  = txt.text;
			txtInp.setFocus();
			txtInp.setSelection(0, 100);
			txtInp.addEventListener(KeyboardEvent.KEY_UP, txtInpKeyUpHandler);
			txtInp.addEventListener(MouseEvent.CLICK, txtInpClickHandler);
		}
		
		private function txtInpKeyUpHandler(kbEvt:KeyboardEvent):void
		{
			if(kbEvt.keyCode == 13)
			{
				txtInp.removeEventListener(KeyboardEvent.KEY_UP, txtInpKeyUpHandler);
				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
				
				txt.text = txtInp.text;
				txtInp.visible = false;
			}
		}
		
		private function txtInpClickHandler(msEvt:MouseEvent):void
		{
				msEvt.stopImmediatePropagation();
		}
		
		private function textAreaDoubleClickHandler(msEvt:MouseEvent):void
		{
			
			textArea.editable = true;
			textArea.selectable = true;
			textArea.focusEnabled = true;
			textArea.setFocus();
			textArea.setStyle('fontWeight', "normal"); 
			textArea.addEventListener(MouseEvent.CLICK, textAreaClickHandler);
		}
		
		private function textAreaClickHandler(msEvt:MouseEvent):void
		{
			msEvt.stopImmediatePropagation();
		}
		
		private function endFormatinfHandler(msEvt:MouseEvent):void
		{
			if(txtInp.visible)
			{
				txtInp.removeEventListener(MouseEvent.CLICK, txtInpClickHandler);
				
				txt.text = txtInp.text;
				txtInp.visible = false;
			}
			
			if(textArea.editable  )
			{
				textArea.removeEventListener(MouseEvent.CLICK, textAreaClickHandler);
				textArea.editable = false;
				textArea.selectable = false;
				textArea.setStyle('fontWeight', "bold");
			}
		}
		
		
		private function lineClickHandler(msEvt:MouseEvent):void
		{
		//	trace('Я нажата');
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE, _ID));
		}
		
		private function deleteClickHandler(msEvt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, _ID));	
		}
		
		public function set sourseImg(obj:Object):void
		{
			image.source = obj;
		}
		
		
			// при нажатии кнопки свернуть
		public function set resize(blHide:Boolean):void
		{
			// убираем "лишнее"
			if (min){
				removeChild(cnvDownLayer);
				min = false;
			}else{
				addChild(cnvDownLayer);
				min = true;
			}

			isRedraw = true;
		}
		
		private function btLessenOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
	
		
		override public function set name(names:String):void
		{
			txt.text = names;
		//	ID = names;
		}
		
		public function set ID(names:String):void
		{
			//txt.text = names;
			_ID = names;
		}
		
		public function get ID():String
		{
			//txt.text = names;
			return _ID;
		}
		
		private function set current(data:Boolean):void
		{
		/*	if (data)
				drawRect();
			else 
				rect.graphics.clear();*/
		}
		
		public function set resourceID(names:String):void
		{
			//txt.text = names;
			_resourceID = names;
		}
		
		public function get resourceID():String
		{
			//txt.text = names;
			return  _resourceID;
		}
		
		
		private function dispStartDrag(evt:MouseEvent):void
		{
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAG, _ID));
		}
		 
		 public function set description(names:String):void
		{
			textArea.text = names;
		}
		
		public function get description():String
		{
			return  textArea.text;
		}
		
		 public function set type(names:String):void
		{
			_type.text = names;
		}
		
		public function get type():String
		{
			return  _type.text;
		}
		 
		
		/* 
		private function draawRect():void
		{
		//	rect.graphics.lineStyle(1, 1, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		//	rect.graphics.drawRect(0, 0, this.width, this.height);
		}
		*/
	
	}
}