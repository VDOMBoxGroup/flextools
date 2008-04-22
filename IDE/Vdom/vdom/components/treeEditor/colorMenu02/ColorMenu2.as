package vdom.components.treeEditor.colorMenu02
{
	import mx.containers.Canvas;
	import mx.controls.Image;
	
	import vdom.events.TreeEditorEvent;

	public class ColorMenu2 extends Canvas
	{
		[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='rMenu')]
		[Bindable]
		public var rMenu:Class;
		public var masLevels:Array;
		private var levels:Levels = new Levels();
		private var slctLevel:Number;
			
		public function ColorMenu2()
		{
			//TODO: implement function
			super();
			var imgBackGround:Image = new Image();
			imgBackGround.source = rMenu;
			addChild(imgBackGround);
			slctLevel = 0;
			creatLevels();
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
		public function showLevel(level:String):Boolean
		{
			var intLevel:Number = Number(level);
			return masLevels[intLevel].status;
		}
		
		private function selectedLevelHandler(trEvt:TreeEditorEvent):void
		{
			if(slctLevel.toString() != trEvt.ID){
				masLevels[slctLevel].unSelect();
				slctLevel =  Number(trEvt.ID);
			}
		//	trace('Color menu: ' +  slctLevel);
		}
	
		private function dispasher(treEvt:TreeEditorEvent):void
		{
		//	trace(treEvt);
			dispatchEvent(new TreeEditorEvent(treEvt.type, treEvt.ID));
		}
	}
}