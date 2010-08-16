package
{
	import flash.display.*;
	import flash.events.*;
	
	public class Cls extends Sprite
	{
		public function Cls()
		{
			graphics.beginFill(0, .4);
			graphics.drawRect(10,10,100,100);
			addEventListener('enterFrame', function(e:Event) {
				rotation += 10;
			});
		}
	}
}


package pack1
{
	import pack2.*;
	
	class FooClass extends BarClass
	{
		public var foo1:FooClass;
		public var foo2:BarClass;
		
		public function fooFn():FooClass
		{
			var local1:Array = [];
			
			local1
			bar
			return null;
		}
	}
}

package pack2
{
	import pack1.*;
		
	class BarClass
	{
		private var bar:FooClass;
		
		public function barFn():BarClass
		{
			return null;
		}

		public var 	bar1;
		public var 	bar2;
		public var 	bar3;
		private var bar4;
		private var bar5;
		private var bar6;
		private var bar7;
		private var bar8;
		private var bar9;
	}
}