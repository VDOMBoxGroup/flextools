package vdom.components.treeEditor
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.VRule;
	import mx.effects.Fade;

	public class TreeButton extends Canvas
	{
		[Embed(source='/assets/treeEditor/new_page.png')]
		[Bindable]
        public var new_page:Class;
        
        [Embed(source='/assets/treeEditor/selected_back_ground.png')]
		[Bindable]
        public var selected_back_ground:Class; 
        
        [Embed(source='/assets/treeEditor/back_ground.png')]
		[Bindable]
        public var back_ground:Class; 

		
		private var _icon:Image = new Image();
		private var _backGround:Image = new Image();
		private var dissolveIn:Fade = new Fade();
		private var dissolveOut:Fade = new Fade();
		private var _label:Label = new Label();	
		
		public function TreeButton()
		{
			super();
			
			percentWidth = 100;
			
			var spaceImg:Image = new Image();
			spaceImg.maintainAspectRatio = false;
			spaceImg.scaleContent = true;
			spaceImg.percentWidth = 100;
			spaceImg.source = back_ground;
//			spaceImg.alpha = 0.1;
			addChild(spaceImg);
			
			dissolveIn.alphaFrom = 0.0;
			dissolveIn.alphaTo   = 1.0;
			dissolveIn.duration  = 100;
			dissolveIn.target = _backGround;
			
			
			dissolveOut.alphaFrom = 1.0;
			dissolveOut.alphaTo   = 0.0;
			dissolveOut.duration  = 100;
			dissolveOut.target = _backGround;
			
			
			_backGround.maintainAspectRatio = false;
			_backGround.scaleContent = true;
			_backGround.source = selected_back_ground;
			_backGround.percentWidth = 100;
			_backGround.alpha = 0.0;
//			_backGround.hideEffect="{dissolveOut}" showEffect="{dissolveIn}"
			addChild(_backGround);

              addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
              addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
              addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
              addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			_icon.source = new_page;
			_icon.width = 23;
			_icon.height = 23;
			addChild(_icon);
			
			var vLine:VRule = new VRule();
			vLine.x = 26;
			vLine.y = 4;
			vLine.height = 15;
			addChild(vLine);
			
//			var _label:Label = new Label();	
			_label.x =  vLine.x + 5;
			_label.y = 2; 
			_label.text = "Button";
			_label.setStyle('fontWeight', "bold");
			addChild(_label);
		}
		
		private function mouseOverHandler(msEvt:MouseEvent):void
		{
			 _backGround.alpha = 1;
		}
		
		private function mouseOutHandler(msEvt:MouseEvent):void
		{
			_backGround.alpha = 0;
			
		}
		
		private function mouseDownHandler(msEvt:MouseEvent):void
		{
			_backGround.alpha = 0.3;
		}
		
		private function mouseUpHandler(msEvt:MouseEvent):void
		{
			_backGround.alpha = 1;
		}
	
		public function set iconBt(obj:Object):void
		{
			if(obj) _icon.source = obj;
		}
		
		public function set labelBt(value:String):void
		{
//			super.label = value;
			_label.text = value;
		}
		
		public function set mark(bl:Boolean):void
		{
			if(bl)
			{
				_label.setStyle("color", "0xFF0000");
//	btSave.setStyle("borderColor", "0xAAB3B3");
			}else
			{
				_label.setStyle("color", "0x000000");
			}
		}
		
	}
}