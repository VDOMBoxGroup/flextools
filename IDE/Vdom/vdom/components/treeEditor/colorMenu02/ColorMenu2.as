package vdom.components.treeEditor.colorMenu02
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
	import vdom.events.TreeEditorEvent;

	public class ColorMenu2 extends Canvas
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='rMenu')]
		[Bindable]
		public var rMenu:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='openEye')]
		[Bindable]
		public var openEye:Class;
		
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='closeEye')]
		[Bindable]
		public var closeEye:Class; 
		
		public var masLevels:Array;
		private var levels:Levels = new Levels();
		private var slctLevel:Number;
		private var eye:Image;	
		private var eyeOpend:Boolean = true;
		private var  textLabel:Label;
		
		public function ColorMenu2()
		{
			addEventListener(FlexEvent.SHOW, showHandler);
			addEventListener(FlexEvent.HIDE, hideHandler);
			
			//TODO: implement function
			super();
			var imgBackGround:Image = new Image();
			imgBackGround.source = rMenu;
			addChild(imgBackGround);
			slctLevel = 0;
			
			
				textLabel = new Label();
//				textLabel.text = ;
				//textLabel.x = ;
				textLabel.y = 2;
				textLabel.width = 190;
				textLabel.setStyle("color", "0xFFFFFF");
				textLabel.setStyle('fontWeight', "bold"); 
				textLabel.setStyle('textAlign', 'center');
			addChild(textLabel);
			
			eye = new Image();
			eye.x = 5;
			eye.y = 5;
			eye.width = 20;
			eye.height = 10;
			eye.source = openEye;
			eye.addEventListener(MouseEvent.CLICK, eyeClickHandler);
			addChild(eye);
			
		}
		
		private function showHandler(flEvt:FlexEvent):void
		{
			
		}
		
		private function hideHandler(flEvt:FlexEvent):void
		{
//			removeLevels();
		}
		
		private function removeLevels():void
		{
			for (var i:int = 0; i < levels.length; i++)
			{
				removeChild(masLevels[i]);
			}
			masLevels = [];
		}
		
		private function eyeClickHandler (msEvt:MouseEvent):void
		{
			eyeOpend = !eyeOpend;
			if(eyeOpend)
			{
				eye.source = openEye;
				
			}else
			{
				eye.source = closeEye;
			}
			
			for(var i:String in masLevels)
			{
				masLevels[i].status = eyeOpend;
			}
			
			
		}
		
		private function creatLevels():void
		{
			masLevels = new Array();
			for (var i:int = 0; i < levels.length; i++)
			{
				masLevels[i] = new Level(levels.getLevel(i));
				masLevels[i].y = i * 25 + 25;
				masLevels[i].x = 2;
			
				masLevels[i].addEventListener(TreeEditorEvent.HIDE_LINES, dispasher);
				masLevels[i].addEventListener(TreeEditorEvent.SHOW_LINES, dispasher);
				masLevels[i].addEventListener(TreeEditorEvent.SELECTED_LEVEL, selectedLevelHandler);
				addChild(masLevels[i]);
			}
			masLevels[slctLevel].select(); 
		}
		
		public function get  selectedItem():Object
		{
			return levels.getLevel(slctLevel);
		}
		public function get openedEyeOfSelectedLevel():Boolean
		{
			return masLevels[slctLevel].status;
		}
		
		public function showLevel(level:String):Boolean
		{
			var intLevel:Number = Number(level);
			return masLevels[intLevel].status;
		}
		
		private function selectedLevelHandler(trEvt:TreeEditorEvent):void
		{
			if(slctLevel.toString() != trEvt.ID)
			{
				masLevels[slctLevel].unSelect();
				slctLevel =  Number(trEvt.ID);
			}
			dispatchEvent(new TreeEditorEvent(TreeEditorEvent.SELECTED_LEVEL, trEvt.ID));
		//	trace('Color menu: ' +  slctLevel);
		}
	
		private function dispasher(treEvt:TreeEditorEvent):void
		{
		//	trace(treEvt);
			dispatchEvent(new TreeEditorEvent(treEvt.type, treEvt.ID));
		}
		
		public function set text(str:String):void
		{
			textLabel.text = str;
			creatLevels();
		}
	}
}