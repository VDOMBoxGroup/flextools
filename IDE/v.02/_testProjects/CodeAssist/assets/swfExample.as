package
{
	import flash.display.*;
	import flash.events.*;

	public class Main extends Sprite
	{
		public function Main()
		{
			addEventListener('addedToStage', function(e:Event)
			{
				stage.scaleMode = 'noScale';
				stage.align = 'TL';
				stage.frameRate = 30;
			});
			
			x = y = 200;
			var a:Array = [];
			for (var i:uint = 0; i < 30; i++)
			{
				var s:Shape = new Shape;
				s.graphics.clear();
				s.graphics.beginFill(i * 0x90000 + i * 0x10, .07);
				s.graphics.drawRoundRect(10+i, 10+i, 120, 120, 30);
				s.graphics.endFill();
				addChild(s);
				a.push(s);
			}
			addEventListener('enterFrame', function(e:Event)
			{
				var i:uint;
				for each(s in a)
					s.rotation += i++/3;

				rotation += .6;
				rotationY += .4;
			});
		}
	}
}

