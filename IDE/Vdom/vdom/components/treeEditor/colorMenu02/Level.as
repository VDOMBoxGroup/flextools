package vdom.components.treeEditor.colorMenu02
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	
	import vdom.events.TreeEditorEvent;

	public class Level extends Canvas
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='level')]
		[Bindable]
		public var level:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='openEye')]
		[Bindable]
		public var openEye:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='closeEye')]
		[Bindable]
		public var closeEye:Class; 
		
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='selectedLevel')]
		[Bindable]
		public var selectedLevel:Class; 
		
		 
		private var _data:Object = new Object();
		private var eyeFlag:Boolean = true;
		private var imgEye:Image = new Image();
		private var imgBackGround:Image;
		
		public function Level(obj:Object)
		{
			//TODO: implement function
			super();
			_data = obj;
			imgBackGround = new Image();
			imgBackGround.source = level;
			addChild(imgBackGround);
			
			
			imgEye.source = openEye;
			imgEye.x = 4;
			imgEye.y = 4;
			imgEye.addEventListener(MouseEvent.CLICK, imgEyeClickHandler);
			addChild(imgEye);
			
			var canColorSquare:Canvas = new Canvas();
			canColorSquare.graphics.lineStyle(1, 0x000000, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			canColorSquare.graphics.beginFill(_data.data,  1);
			canColorSquare.graphics.drawRect(160, 5, 10, 10);
			addChild(canColorSquare);
			
			var label:Label = new Label;
			label.text =  resourceManager.getString('Tree','level') + ' '+ _data.level;
			label.x = 30;
			label.y = 3;
			label.width = 120;
			label.setStyle('fontWeight', "bold"); 
			label.setStyle('textAlign', 'center');
			addChild(label);
			
			addEventListener(MouseEvent.CLICK, mouseClickHandler)
		}
		
		private function imgEyeClickHandler(msEvt:MouseEvent):void
		{
//			trace('mouse down'+ eyeFlag);
			eyeFlag = !eyeFlag;
			if(!eyeFlag){
				imgEye.source = closeEye;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.HIDE_LINES, _data.level));
//				trace('mouse down'+ eyeFlag);
			}else{
				imgEye.source = openEye;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SHOW_LINES, _data.level));
			}	
			
			msEvt.stopImmediatePropagation();
//			trace('mouse down');
		}
		
		public function set status(bl:Boolean):void
		{
			eyeFlag = bl;
			
			if(!eyeFlag){
				imgEye.source = closeEye;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.HIDE_LINES, _data.level));
			}else{
				imgEye.source = openEye;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SHOW_LINES, _data.level));
			}	
		}
		
		private function mouseClickHandler(msEvt:MouseEvent):void
		{
			imgBackGround.source = selectedLevel;
			
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SELECTED_LEVEL, _data.level));
			//trace('Lavel: ' + _data.level  );
		}
		
		public  function unSelect():void
		{
			imgBackGround.source = level;
			//dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SELECTED_LEVEL, _data.level));
			//trace('Lavel: ' + _data.level  );
		}
		
		public  function select():void
		{
			imgBackGround.source = selectedLevel;
			//dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SELECTED_LEVEL, _data.level));
			//trace('Lavel: ' + _data.level  );
		}
		
		public function get status():Boolean
		{
			return eyeFlag;
		}
		
		/*
		private function dispasher(treEvt:TreeEditorEvent):void
		{
		//	trace(treEvt);
			dispatchEvent(new TreeEditorEvent(treEvt.type, treEvt.ID));
		}
		*/
		
	}
}