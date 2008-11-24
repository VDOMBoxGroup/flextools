package vdom.components.treeEditor.colorMenu02
{
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.VRule;
	
	import vdom.events.TreeEditorEvent;

	public class Level extends Canvas
	{
		
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='openEye')]
		[Bindable]
		public var openEye:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='closeEye')]
		[Bindable]
		public var closeEye:Class; 
		/*
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='level')]
		[Bindable]
		public var level:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='selectedLevel')]
		[Bindable]
		public var selectedLevel:Class; 
		*/
		
		[Embed(source='/assets/treeEditor/selected_back_ground.png')]
		[Bindable]
        public var selectedLevel:Class; 
        
        [Embed(source='/assets/treeEditor/back_ground.png')]
		[Bindable]
        public var level:Class; 
		 
		private var _data:Object = new Object();
		private var eyeFlag:Boolean = true;
		private var imgEye:Image = new Image();
		private var imgBackGround:Image;
		private var desabledEye:Canvas = new Canvas();
		private var myShape:Canvas = new Canvas();
		
		public function Level(obj:Object)
		{
			//TODO: implement function
			super();
			percentWidth = 100;
			_data = obj;
			imgBackGround = new Image();
			imgBackGround.maintainAspectRatio = false;
			imgBackGround.scaleContent = true;
			imgBackGround.percentWidth = 100;
			imgBackGround.source = level;
			addChild(imgBackGround);
			
			
			imgEye.source = openEye;
			imgEye.x = 4;
			imgEye.y = 4;
			imgEye.addEventListener(MouseEvent.CLICK, imgEyeClickHandler);

		            var gradientBoxMatrix:Matrix = new Matrix();
		  
		            gradientBoxMatrix.createGradientBox(100, 30, Math.PI/2, 0, -2);  
		            
		 
		           	myShape.graphics.beginGradientFill(GradientType.LINEAR, [_data.data,
		             0x000000], [1, 1], [0, 255], gradientBoxMatrix);
		            myShape.graphics.lineStyle(2, 0x000000, 0.3, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
		            myShape.graphics.drawCircle(0, 0, 6);  
		            myShape.graphics.endFill();
		           
		           	myShape.graphics.lineStyle(4, 0xFFFFFF, 0.4, false, LineScaleMode.NONE, 
		           	 CapsStyle.SQUARE, JointStyle.MITER);
		            myShape.x = 12;
		            myShape.y = 11;  
		            addChild(myShape);
		            myShape.addEventListener(MouseEvent.CLICK, imgEyeClickHandler); 
		            
		            
		            	desabledEye.graphics.beginFill(0xAAAAAA);
		            	desabledEye.graphics.lineStyle(1);
		            	desabledEye.graphics.drawCircle(0, 0, 6);
		            	desabledEye.graphics.endFill();
		            	
		            desabledEye.x = 12;
		            desabledEye.y = 11;
		            desabledEye.visible = false;
		            addChild(desabledEye);
		            desabledEye.addEventListener(MouseEvent.CLICK, imgEyeClickHandler);	
		            
		            
		            	
			//----------
			
			var vLine:VRule = new VRule();
				vLine.height = 14;
				vLine.x = 23;
				vLine.y = 4;
			addChild(vLine);
			
			var label:Label = new Label;
			label.text =  resourceManager.getString('Tree','level') + ' '+ _data.level;
			label.x = 30;
			label.y = 3;
//			label.width = 120;
			label.setStyle('fontWeight', "bold"); 
//			label.setStyle('textAlign', 'center');
			addChild(label);
			
			addEventListener(MouseEvent.CLICK, mouseClickHandler)
		}
		
		private function imgEyeClickHandler(msEvt:MouseEvent):void
		{
//			trace('mouse down'+ eyeFlag);
			eyeFlag = !eyeFlag;
			if(!eyeFlag){
				desabledEye.visible = true;
				imgEye.source = closeEye;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.HIDE_LINES, _data.level));
//				trace('mouse down'+ eyeFlag);
			}else{
				desabledEye.visible = false;;
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
				desabledEye.visible = true;
				imgEye.source = closeEye;
				dispatchEvent(new TreeEditorEvent(TreeEditorEvent.HIDE_LINES, _data.level));
			}else{
				desabledEye.visible = false;
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