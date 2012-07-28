package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class PreferencesWindowEvent extends Event
	{
		public static var APPLY : String = "preferencesWindowEventApply";
		
		public static var CANCEL : String = "preferencesWindowEventCancel";
		
		public function PreferencesWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new PreferencesWindowEvent( type, bubbles, cancelable );
		}
	}
}