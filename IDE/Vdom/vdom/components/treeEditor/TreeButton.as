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

		
		private var _icon:Image = new Image();
		private var _backGround:Image = new Image();
		private var dissolveIn:Fade = new Fade();
		private var dissolveOut:Fade = new Fade();
		
		public function TreeButton()
		{
			super();
			
			percentWidth = 100;
			
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
			
			_icon.source = new_page;
			addChild(_icon);
			
			var vLine:VRule = new VRule();
			vLine.x = 23;
			vLine.y = 4;
			vLine.height = 15;
			addChild(vLine);
			
			var _label:Label = new Label();	
			_label.x =  vLine.x + 5;
			_label.y = 2; 
			_label.text = "Button";
			_label.setStyle('fontWeight', "bold");
			addChild(_label);
			
			var spaceImg:Image = new Image();
			spaceImg.source = selected_back_ground;
			spaceImg.alpha = 0.1;
			addChild(spaceImg);
			
			
		}
		
		private function mouseOverHandler(msEvt:MouseEvent):void
		{
			 _backGround.alpha = 1;
//			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
//			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
//			if(_backGround.alpha == 0)
//			dissolveIn.play();
		}
		
		private function mouseOutHandler(msEvt:MouseEvent):void
		{
			_backGround.alpha = 0;
			/*
			trace("Stop: 1.0 - " + _backGround.alpha);
//			removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
//			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			if( _backGround.alpha != 0 && _backGround.alpha != 1)
				dissolveOut.alphaFrom = _backGround.alpha;
			else 
				dissolveOut.alphaFrom = 1;
				
			dissolveOut.play();
			*/
//			super.icon
		}
	
		public function set iconBt(obj:Object):void
		{
			if(obj) _icon.source = obj;
		}
		
	}
}