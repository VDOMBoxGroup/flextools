package vdom.components.treeEditor
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	
	import vdom.events.IndexEvent;

	public class Index extends Canvas
	{
		private var cmBox:ComboBox;
		private var lbIndex:Label;
		
		public function Index()
		{
			super();
			
			lbIndex = new Label();
			buttonMode = true;
			
//			lbIndex.text = '3'; 
//			index = '3';
			
			lbIndex.addEventListener(MouseEvent.CLICK, indexClickHandler);
			addChild(lbIndex);
		}
		
		private function creatingComboBox():void
		{
			cmBox = new ComboBox();
//			cmBox.visible = false;
			cmBox.width = 50;
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
			index =  newIndex;
//			trace('comboBoxChangeHandler')
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
//			maxIndex = '30';
			cmBox.dataProvider = comboBoxData;
			cmBox.validateProperties();
			invalidateDisplayList();
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
//			cmBox.dataProvider = comboBoxData;
//			cmBox.validateNow();
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
			trace('new: '+lbIndex.text)
			
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
			
			this.visible = _targetLine.visible;
		}
		
		/***
		 *
		 * 		 remove
		 * 
		 */
		 public function remove():void
		 {
		 	_fromObjectID = null;
//		 	parent.rawChildren.removeChild(this);
			
			visible = false;
		 	parent.removeChild(this);
		 	
		 }
	}
}