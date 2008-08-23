package vdom.components.treeEditor
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	import mx.containers.Canvas;
	import mx.core.Container;
	
	public class TreeVector extends Vector2
	{
		private var trEl0:Object;
		private var trEl1:Object;
		private var vector:Container = new Container();
		private var curСolor:String = '';
		//private var button:Button;
		
		
		public function TreeVector(trEl0:Object, trEl1:Object, level:String = '1'):void
		{
			super(); 
					
			this.buttonMode = true;
			color = level;
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
		
//		private var _visibleIndex:Boolean = true;
		
		
	/*	
		public  function set mark(bool:Boolean):void
		{
			if(bool)
			{
				this._mark = true;
				drawLine();
			}
			else
			{
				this._mark = false;
				drawLine();
		//	trace('mark = fulse')
			}
		}
		*/
		
	}
}