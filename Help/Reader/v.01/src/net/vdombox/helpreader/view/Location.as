package net.vdombox.helpreader.view
{
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.controls.Label;

	public class Location extends Canvas
	{
		
		private var lb:Label = new Label();
		public function Location(data:XML)
		{
			super();
			
				lb.text = data.@title;
				lb.setStyle("color", "#0000AA");
				
			addChild(lb);
			
			_addreess = data.@name;
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseUverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, 	mouseOutHandler);
		}
		
		private var _addreess : String;
		public  function get addreess():String
		{
			return _addreess;
		}
		
		
		private function mouseUverHandler(msEvt:MouseEvent):void
		{
			lb.setStyle("textDecoration", "underline");
		}
		
		private function mouseOutHandler(msEvt:MouseEvent):void
		{
			lb.setStyle("textDecoration", "none");
		}
	}
	
}