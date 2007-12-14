package vdom.components.treeEditor.colormenu
{
	public class Levels 
	{
		private var dataArr:Array = 
		[
		{label:'lavel 0', data:0x00ff00, level:0},
		{label:'lavel 1', data:0xffff00, level:1},
		{label:'lavel 2', data:0x00ffff, level:2},
		{label:'lavel 3', data:0xff0000, level:3},
		{label:'lavel 4', data:0xff00ff, level:4},
		{label:'lavel 5', data:0xcccc00, level:5},
		{label:'lavel 6', data:0xffcccc, level:6},
		{label:'lavel 7', data:0xccffcc, level:7},
		{label:'lavel 8', data:0xff0000, level:8}
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
	}
}