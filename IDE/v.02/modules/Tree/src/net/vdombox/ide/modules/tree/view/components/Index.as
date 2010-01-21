package net.vdombox.ide.modules.tree.view.components
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	
	import vdom.components.treeEditor.colorMenu02.Levels;
	import vdom.events.IndexEvent;

	public class Index extends Canvas
	{
		private var cmBox:ComboBox;
		private var lbIndex:Label;
		private var lbIndex_w:Label;
		
		public function Index()
		{
			super();
			
			clipContent = false;
			
			lbIndex = new Label();
			lbIndex.x = -9;
			lbIndex.y = -8;
			lbIndex.width = 19;
			lbIndex.setStyle('fontWeight', "bold");
			lbIndex.setStyle('textAlign', 'center');
			lbIndex.buttonMode = true;
			addChild(lbIndex);
			
			lbIndex_w = new Label();
			lbIndex_w.x = -10;
			lbIndex_w.y = -9;
			lbIndex_w.width = 19;
			
			lbIndex_w.setStyle('fontWeight', "bold");
			lbIndex_w.setStyle('textAlign', 'center');
			lbIndex_w.setStyle('color', '0xFFFFFF');
			lbIndex_w.buttonMode = true;
			
			addChild(lbIndex_w);

			buttonMode = true;
			addEventListener(MouseEvent.CLICK, indexClickHandler);
		}
		
		override public function set visible(value:Boolean):void
	    {
	        super.visible = value;
	    }
		private function creatingComboBox():void
		{
			cmBox = new ComboBox();
			cmBox.width = 53;
			cmBox.x = 15;
			cmBox.visible = false;
			
			if(comboBoxData)
			{	cmBox.dataProvider = comboBoxData;
				cmBox.validateNow();
			}
			cmBox.addEventListener(Event.CLOSE, comboBoxCloseHandler);
			cmBox.addEventListener(Event.CHANGE, comboBoxChangeHandler);
			addChild(cmBox);
		}
		
		private function comboBoxChangeHandler(evt:Event):void
		{
			var newIndex:int = ComboBox(evt.currentTarget).selectedIndex + 1
			dispatchEvent(new IndexEvent(IndexEvent.CHANGE, newIndex, index, _level, _fromObjectID)); 
			
			callLater(setData);
			
			function setData():void
			{
				index =  newIndex;
			} 
		}
		
		private function comboBoxCloseHandler(evt:Event):void
		{
			cmBox.visible = false;
		}
		
		
		private function indexClickHandler(msEvt:MouseEvent):void
		{
			
			if(!cmBox)
				creatingComboBox();
			if(cmBox.visible)
				return;
			
			cmBox.visible = true;
			cmBox.dataProvider = comboBoxData;
			cmBox.validateProperties();
			invalidateDisplayList();
			cmBox.setFocus();
			cmBox.selectedIndex = Number(index) - 1;
			cmBox.callLater(cmBox.open);
			
		}
		
		private function targetLineChangeHandler(evt:Event):void
		{
			updateXY();
		}
		
		/***
		 *
		 * 		 level
		 * 
		 */
		private var _level:String;
		public function get level():String
		{
			return _level;
		}
		
		public function set level(str:String):void
		{
			_level = str;
			
			var levels:Levels = new Levels();
			var color:Number = levels.getColor(_level);
			
			graphics.lineStyle(1, color, .01, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.drawCircle(0, 0, 15);
			
			graphics.lineStyle(12, color, .1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			graphics.beginFill(color);
			graphics.drawCircle(0, 0, 11);
			graphics.endFill();
			
			
			graphics.lineStyle(1, 0x000000, .4, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
//			
//			graphics.beginFill(0xffffff);
			graphics.drawCircle(0, 0, 10);
//			graphics.endFill();
			validateDisplayList();
		}
		
		/***
		 *
		 * 		 fromObjectID
		 * 
		 */
		
		private var _fromObjectID:String;
		public function get fromObjectID():String
		{
			return _fromObjectID
		}
		
		public function set fromObjectID(str:String):void
		{
			_fromObjectID = str;
		}
		
		/***
		 *
		 * 		 maxIndex
		 * 
		 */
		private var _maxIndex:int;
		public function get maxIndex():int
		{
			return _maxIndex;
		}
		
		private var comboBoxData:Array = new Array(); 
		public function set maxIndex(num:int):void
		{
			_maxIndex = num;
			
			comboBoxData = [];
			for(var i:int = 0; i < _maxIndex; i++)
			{
				comboBoxData[i] = new Array();
				comboBoxData[i]['label'] = i+1;
				comboBoxData[i]['data'] = i+1;
			}
		}
		
		
		
		
		/***
		 *
		 * 		 index
		 * 
		 */
		private var _index:int;
		public function get index():int
		{
			return _index;
		}
		
		public function set index(num:int):void
		{
			_index = num;
			lbIndex.text = _index.toString(); 
			lbIndex_w.text = _index.toString(); 
			
		}
		
		
		/***
		 *
		 * 		 targetLine
		 * 
		 */
		private var _targetLine:TreeVector;
				
		public function set targetLine(obj:TreeVector):void
		{
			_targetLine = obj;
			
			_targetLine.addEventListener(Event.CHANGE, targetLineChangeHandler);
			
			updateXY();
		}
		
		
		/***
		 *
		 * 		 updateXY
		 * 
		 */
		public function updateXY():void
		{
			this.x = _targetLine.middleX;
			this.y = _targetLine.middleY;
		}
		
		/***
		 *
		 * 		 remove
		 * 
		 */
		 public function remove():void
		 {
		 	_fromObjectID = null;
			
			visible = false;
		 	parent.removeChild(this);
		 	
		 }
	}
}