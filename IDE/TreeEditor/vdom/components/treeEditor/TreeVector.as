package vdom.components.treeEditor
{
	import mx.core.Container;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.geom.Point;
	import flash.net.ObjectEncoding;
	
	public class TreeVector extends Vector
	{
		private var trEl0:TreeElement;
		private var trEl1:TreeElement;
		private var vector:Container = new Container();
		
		public function TreeVector(trEl0:TreeElement, trEl1:TreeElement, level:String):void
		{
//			trEl0:TreeElement, trEl1:TreeElement, level:String //
			this.buttonMode = true;
			this.color = level;
			this.trEl0 = trEl0;
			this.trEl1 = trEl1;
			createVector (trEl0,  trEl1);
		}
		
		public function updateVector():void
		{
			graphics.clear();
			createVector (trEl0,  trEl1);
		}
		
	}
}