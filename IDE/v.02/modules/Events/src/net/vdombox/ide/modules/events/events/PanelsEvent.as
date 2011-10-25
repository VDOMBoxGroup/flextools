package net.vdombox.ide.modules.events.events
{
	import flash.events.Event;

	public class PanelsEvent extends Event
	{
		
		public static var EYES_CLICK : String = "eyesClick";
		public static var DATE_SETTED : String = "dataSetted";
		
		public function PanelsEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new PanelsEvent( type, bubbles, cancelable );
		}
	}
}