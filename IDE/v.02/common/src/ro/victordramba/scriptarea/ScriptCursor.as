package ro.victordramba.scriptarea
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.utils.setInterval;

	internal class ScriptCursor extends Sprite
	{
		public static var height:int;
		private var crs:Shape;
		
		private var w : int;
		private var h : int;
		
		private var _color : uint = 0x000000;
		
		public function ScriptCursor()
		{
			setInterval(redraw, 500);
			crs = new Shape;
			addChild(crs);
		}
		
		private function redraw():void
		{
			b = !b;
			crs.graphics.clear();
			if (b)
			{
				crs.graphics.beginFill(_color, 1);
				crs.graphics.drawRect(0, 0, 2, ScriptCursor.height);
			}
		}
		
		public function set color( value : uint ) : void
		{
			_color = value;
			redraw();
		}
		
		public function pauseBlink():void
		{
			b = false;
			redraw();
			b = false;
		}
		
		public function setSize(w:int, h:int):void
		{
			this.w = w;
			this.h = h;
			graphics.clear();
			var m:Matrix = new Matrix;
			m.createGradientBox(w, h, Math.PI/2);
			graphics.beginGradientFill(GradientType.LINEAR, [0,0], [0.04,.09],[0,255], m);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
		}
		
		public function setX(x:int):void
		{
			crs.x = x;
		}
		
		public function getX():int
		{
			return crs.x;
		}
		
		private var b:Boolean = true;
	}
}