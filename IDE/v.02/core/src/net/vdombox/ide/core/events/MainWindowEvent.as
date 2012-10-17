package net.vdombox.ide.core.events
{
	import flash.events.Event;
	
	public class MainWindowEvent extends Event
	{
		public static var CLOSE : String = "mainWindowClose";
		public static var LOGOUT : String = "logout";
		public static var SHOW_APP_MANAGER : String = "showAppManager";
		
		public function MainWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new MainWindowEvent( type, bubbles, cancelable );
		}
	}
}