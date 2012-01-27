package net.vdombox.ide.common.events
{
	import flash.events.Event;
	
	public class CreateActionWindowEvent extends Event
	{
		public static var PERFORM_CREATE : String = "performCreate";
		
		public static var PERFORM_CANCEL : String = "performCancel";
		
		public function CreateActionWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new CreateActionWindowEvent( type, bubbles, cancelable );
		}
	}
}