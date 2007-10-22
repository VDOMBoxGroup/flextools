package vdom.components.treeEditor
{
	import mx.core.Container;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.geom.Point;
	import flash.net.ObjectEncoding;
	import mx.controls.Button;
	
	public class TreeVector extends Vector
	{
		private var trEl0:TreeElement;
		private var trEl1:TreeElement;
		private var vector:Container = new Container();
		private var curСolor:String = '';
		//private var button:Button;
		
		
		public function TreeVector(trEl0:TreeElement, trEl1:TreeElement, level:String):void
		{
			this.buttonMode = true;
			this.color = level;
			this.curСolor = level;
			this.trEl0 = trEl0;
			this.trEl1 = trEl1;
			createVector (trEl0,  trEl1);
		}
		
		public function updateVector():void
		{
			graphics.clear();
			createVector (trEl0,  trEl1);
		}
		
		public  function set mark(bool:Boolean):void
		{
			if(bool)
			{
				this._mark = true;
				drawLine();
			//	graphics.drawCircle(btX, btY, 2);
			}
			else
			{
				this._mark = false;
				drawLine();
			//	button.visible = false;
		//	trace('mark = fulse')
			}
		}
	}
}