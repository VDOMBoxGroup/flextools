package vdom.components.treeEditor.colorMenu02
{
	public class Levels 
	{
		private var dataArr:Array = 
				[
				{label:'level 0', data:0x00ff00, level:0},
				{label:'level 1', data:0xffff00, level:1},
				{label:'level 2', data:0x00ffff, level:2},
				{label:'level 3', data:0xff0000, level:3},
				{label:'level 4', data:0xff00ff, level:4},
				{label:'level 5', data:0xcccc00, level:5},
				{label:'level 6', data:0xffcccc, level:6},
				{label:'level 7', data:0xccffcc, level:7}
			//	{label:'level 8', data:0xff0000, level:8}
				]
		
		public  function Levels()
		{
			
		}
		
		public function get data():Array
		{
			return dataArr;
		}
		
		public function get topData():Array
		{
			return dataArr[0];
		}
		
		public function getColor(str:String):Number
		{
			return dataArr[Number(str)].data;
		}
		
		public function getLevel(nLevel:Number):Object
		{
			if (nLevel < 9 && nLevel >= 0)  
			return dataArr[nLevel];
			
			trace('Error: class Levels -> function getLevel -> nLevel not availabled  ');
			return new Object();
		}
		
		public function get length():Number
		{
			return dataArr.length;
		}
	}
}