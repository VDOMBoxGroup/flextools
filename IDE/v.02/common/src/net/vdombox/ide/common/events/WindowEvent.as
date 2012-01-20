package net.vdombox.ide.common.events
{
	import flash.events.Event;
	
	public class WindowEvent extends Event
	{
		public static var PERFORM_APPLY : String = "performApply";
		
		public static var PERFORM_CANCEL : String = "performCancel";
		
		public function WindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new WindowEvent( type, bubbles, cancelable );
		}
	}
}