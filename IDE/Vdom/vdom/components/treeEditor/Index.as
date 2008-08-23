package vdom.components.treeEditor
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.ComboBox;
	import mx.controls.Label;

	public class Index extends Canvas
	{
		private var cmBox:ComboBox;
		private var lbIndex:Label;
		
		public function Index()
		{
			super();
			
			lbIndex = new Label();
			lbIndex.text = '1'; 
			lbIndex.addEventListener(MouseEvent.CLICK, indexClickHandler);
			addChild(lbIndex);
		}
		
		private function creatingComboBox():void
		{
			cmBox = new ComboBox();
			cmBox.visible = false;
			cmBox.width = 50;
			addChild(cmBox);
		}
		
		private function indexClickHandler(msEvt:MouseEvent):void
		{
			if(!cmBox) 
				creatingComboBox();
			
			cmBox.visible = true;
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
		private var _maxIndex:String;
		public function get maxIndex():String
		{
			return _maxIndex;
		}
		
		public function set maxIndex(str:String):void
		{
			_maxIndex = str;
		}
		
		
		/***
		 *
		 * 		 index
		 * 
		 */
		private var _index:String;
		public function get index():String
		{
			return index;
		}
		
		public function set index(str:String):void
		{
			_index = str;
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
		 	
		 	trace('removed');
		 }
	}
}