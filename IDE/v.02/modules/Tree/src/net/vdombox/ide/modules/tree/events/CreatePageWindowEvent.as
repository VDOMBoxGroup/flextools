package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;
	
	public class CreatePageWindowEvent extends Event
	{
		public static var PERFORM_CREATE : String = "performCreate";
		
		public static var PERFORM_CANCEL : String = "performCancel";
		
		public function CreatePageWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new CreatePageWindowEvent( type, bubbles, cancelable );
		}
	}
}