package
{
	import flash.display.*;
	import flash.utils.getDefinitionByName;
	import flash.text.*;
	import flash.events.*;
	
	public class Preloader extends MovieClip
	{
		private var txt:TextField;
		
		public function Preloader()
		{
			txt = new TextField;
			txt.defaultTextFormat = new TextFormat('_sans');
			txt.x = (stage.stageWidth - txt.width)/2;
			addChild(txt);
			addFrameScript(1, _frame2);
			addEventListener(Event.ENTER_FRAME, loadStep);
		}
		
		private function loadStep(e:Event):void
		{
			txt.text = 'loading '+Math.round(loaderInfo.bytesLoaded/loaderInfo.bytesTotal*100)+'%';
		}
		
		private function _frame2():void
		{
			removeChild(txt);
			removeEventListener(Event.ENTER_FRAME, loadStep);
			graphics.clear();
			stop();
			var app:* = new (getDefinitionByName('CodeAssist'));
			addChild(app);
			app.init();
		}

	}
}