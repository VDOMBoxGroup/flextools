package vdom.components.eventEditor
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.Grid;
	import mx.containers.GridRow;
	import mx.controls.Button;
	import mx.controls.HRule;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.controls.VRule;
	
	import vdom.events.TreeEditorEvent;
	
	

	public class EventEditorEvent extends Canvas
	{
					
		
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
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='menu')]
		[Bindable]
		public var menu:Class;
		
	
		private var btLine:Button;
		private var btDelete:Button;
		private var btLessen:Button; 
		private var txt:Label;
		private var textArea:TextArea;
		private var _ID:String;
//		private var rect:Canvas = new Canvas();
		private var min:Boolean = true;
		public var drag:Boolean = true;
		private var image:Image;
		private var imgBackGround:Image;
		private var imgPlus:Image;
		private var imgMenu:Image;
		private var imgheader:Image;
		private var imgDelete:Image;
		private var imgType:Image;
		private var imgLine:Image;
		private var cnvUpLayer	:Canvas = new Canvas();
		private var cnvDownLayer:Canvas = new Canvas();		
		private var txtInp:TextInput;
		private var _type:Label;
		//private var dataManager:DataManager;
		private var _ratio:Number = 0.8;
		
	//	public var ID:String = '123';
		
		public function EventEditorEvent(data:Object)
		{
			super();
		//	if (typeof(data)=="string")
		//		trace (data)
			
			_ID = Math.random().toString();
			cnvUpLayer.clipContent = false;
			
			//dataManager = DataManager.getInstance();
			
			initUpBody();
			initDownBody();
			txt.text += ': ' + data.toString(); 
			event.text = data.toString(); 
			
			updateRatio();
			
			isRedraw = true;
		}
		
		private var isRedraw:Boolean;
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (isRedraw) {
				
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.REDRAW_LINES, _ID));
				isRedraw = false;
			}
		}
		
		
		
		
		private function plusClickHandler(msEvt:MouseEvent):void
		{
			min = !min
			changeState(min)
		}
		
		private function lineClickHandler(msEvt:MouseEvent):void
		{
		//	trace('Я нажата');
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_DRAW_LINE, _ID));
		}
		
		private function deleteClickHandler(msEvt:MouseEvent):void
		{
			parent.removeChild(this);
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.DELETE, _ID));	
		}
		
	
		
		
		/****
		 * 
		 * 			resource Browser Launcher
		 * 
		 * 
		 * */
				
			// при нажатии кнопки свернуть
		private function changeState(blHide:Boolean):void
		{
			if (!blHide){
				if(contains(cnvDownLayer))	removeChild(cnvDownLayer);
				imgPlus.source = plus;
			}else{
				addChild(cnvDownLayer);
				imgPlus.source = minus;
			}	
			min = blHide;
			isRedraw = true;
			
		}
		
		private function btLessenOut(muEvt:MouseEvent):void
		{
			this.drag = true;	
		}
	
		
	 
	 private function startDragHandler(msEvt:MouseEvent):void
	 {
	 	if( txtInp.visible == false)
	 	{
	 		dispatchEvent(new TreeEditorEvent(TreeEditorEvent.START_REDRAW_LINES, _ID));
	 		startDrag();
	 	}
	 		
	 }
	  private function stopDragHandler(msEvt:MouseEvent):void
	 {
	  	stopDrag();
	  	dispatchEvent(new TreeEditorEvent(TreeEditorEvent.STOP_REDRAW_LINES, _ID));	
	 }

		

		private function initUpBody():void
		{
			imgheader = new Image();
			imgheader.source = header;
			
			
			//imgheader.maintainAspectRatio = true;
			//imgheader.scaleContent = true;
			
			txt = new Label();
			txt.setStyle('color', '#ffffff');
			txt.setStyle('fontWeight', "bold"); 
			txt.setStyle('textAlign', 'center');
			
			
			txt.buttonMode = true;
			txt.doubleClickEnabled = true;
			txt.text = 'Event';
			//txt.addEventListener(MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler)
			
			imgMenu = new Image();
			imgMenu.source = menu;
			
			
			imgLine = new Image();
			imgLine.source = line;
			imgLine.buttonMode = true;
			
			imgLine.addEventListener(MouseEvent.CLICK, lineClickHandler);
			
			imgDelete = new Image();
			imgDelete.source = delet; 
			imgDelete.buttonMode = true;
			
			imgDelete.addEventListener(MouseEvent.CLICK, deleteClickHandler);
			
			imgPlus = new Image();
			imgPlus.source = minus;
			imgPlus.buttonMode = true;
				
			imgPlus.addEventListener(MouseEvent.CLICK, plusClickHandler);	
			
			txtInp = new TextInput();
			txtInp.setStyle('borderColor', '#000000');
			txtInp.setStyle('fontWeight', "bold"); 
			txtInp.setStyle('textAlign', 'center');
			
			txtInp.visible = false;
			
			cnvUpLayer.addChild(imgheader);
			cnvUpLayer.addChild(imgMenu);
			cnvUpLayer.addChild(txt);
			cnvUpLayer.addChild(imgPlus);
			cnvUpLayer.addChild(txtInp);
			cnvUpLayer.addChild(imgLine);
			cnvUpLayer.addChild(imgDelete);
			
			cnvUpLayer.addEventListener(MouseEvent.MOUSE_DOWN, startDragHandler);
			cnvUpLayer.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler)
			addChild(cnvUpLayer);
			
		}
		
		private var event:Label;
		private var grid:Grid; 
		private var gridRow1: GridRow;
		private var gridRow2: GridRow;
		private var gridRow3: GridRow;
		private function initDownBody():void
		{
			cnvDownLayer.setStyle('backgroundColor',"0xffffff" );
			addChild(cnvDownLayer);
			//addChild(cnvDownLayer);
			
			//draw vertical Line
			var leftVRule:VRule =new VRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
				//vRule.x = 35;
				leftVRule.percentHeight = 100;
			cnvDownLayer.addChild(leftVRule);   
			
			var middleVRule:VRule =new VRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
				middleVRule.x = 25;
				middleVRule.percentHeight = 100;
			cnvDownLayer.addChild(middleVRule);   

			
			var rightVRule:VRule =new VRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
				rightVRule.x = 100;
				rightVRule.setStyle('right', 0);
				rightVRule.percentHeight = 100;
			cnvDownLayer.addChild(rightVRule);   

			///         -- 1 --
						var img1:Image = new Image()
							img1.source = delet;
							img1.x = 5;
							img1.y = 3;
						cnvDownLayer.addChild(img1);
					
						var label1:Label = new Label()
							label1.text = 'MyButton';
							label1.x = middleVRule.x;
							label1.y = 0;
							label1.width = 165;
							label1.setStyle('textAlign', 'center');
						cnvDownLayer.addChild(label1);
						
						var hRule1:HRule =new HRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
							hRule1.y = 17;
							//trace('hRule1.y: ' + hRule1.y );
							hRule1.percentWidth = 100;
						cnvDownLayer.addChild(hRule1);   
							
			///         -- 2 --
						var img2:Image = new Image();
							img2.source = delet;
							img2.x = 5;
							img2.y = hRule1.y + 3;
						cnvDownLayer.addChild(img2);
						
						event = new Label();
							event.width = 165;
							event.x = middleVRule.x;
							event.y = hRule1.y; 
							event.setStyle('textAlign', 'center');
						cnvDownLayer.addChild(event);
						
						var hRule2:HRule =new HRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
							hRule2.percentWidth = 100;
							hRule2.y = event.y + 17;
						cnvDownLayer.addChild(hRule2);
						
						  
			///         -- 3 --
			
						var img3:Image = new Image();
							img3.source = delet;
							img3.x = 5;
							img3.y = hRule2.y + 3;
						cnvDownLayer.addChild(img3);
						
						var labelX:Label = new Label();
							labelX.text = 'X';
							labelX.x = middleVRule.x;
							labelX.y = hRule2.y ; 
							labelX.width = 165;
							labelX.setStyle('textAlign', 'center');
						cnvDownLayer.addChild(labelX);
						
						var hRule3:HRule =new HRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
							hRule3.y = labelX.y + 17;
							hRule3.percentWidth = 100;
						cnvDownLayer.addChild(hRule3);
						
			///         -- 4 --
			
						var img4:Image = new Image();
							img4.source = delet;
							img4.x = 5;
							img4.y =  hRule3.y + 3;
						cnvDownLayer.addChild(img4);
						
						var labelY:Label = new Label();
							labelY.text = 'Y';
							labelY.x = middleVRule.x;
							labelY.y = hRule3.y; 
							labelY.width = 165;
							labelY.setStyle('textAlign', 'center');
						cnvDownLayer.addChild(labelY);
						
						var hRule4:HRule =new HRule(); // rollOverEffect="WipeUp" strokeWidth="1" strokeColor="red"/>   
							hRule4.y = labelY.y + 17;
							hRule4.percentWidth = 100;
						cnvDownLayer.addChild(hRule4);
				
				
		}
		

		private function updateRatio():void
		{	
			imgheader.width = 243 * _ratio;
			imgheader.height = 30 * _ratio;
			
			imgMenu.width = 56 * _ratio;
			imgMenu.height = 14 * _ratio;

			txt.y = 2 * _ratio;
			txt.width =  240 * _ratio;
			
			 
			imgLine.y = -12 * _ratio; 
			imgLine.x = 20 * _ratio;	
			imgLine.width = 10 * _ratio;
			imgLine.height = 10 * _ratio;
			
			//imgDelete 
			imgDelete.y = -12 * _ratio;
			imgDelete.x = 40 * _ratio;	
			imgDelete.width = 10 * _ratio;
			imgDelete.height = 10 * _ratio;
			
			 
			imgPlus.y = -12 * _ratio;
			imgPlus.x = 4 * _ratio;
			imgPlus.width = 10 * _ratio;
			imgPlus.height = 10 * _ratio;
			
		//	txtInp 
			txtInp.y = 2 * _ratio;
			txtInp.width =  240 * _ratio;
			
		//	cnvUpLayer
			//----
			
			cnvDownLayer.y = 30 * _ratio;
			cnvDownLayer.width = 243 * _ratio;
			
		}
		
		public function get ID():String
		{
			return _ID;
		}
	}
}