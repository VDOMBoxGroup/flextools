package net.vdombox.ide.modules.resourceBrowser.events
{
	import flash.events.Event;

	public class ToolsetEvent extends Event
	{
		public static var OPEN_CREATE_APPLICATION : String = "openCreateApplication";
		
		public function ToolsetEvent( type : String, bubbles : Boolean = false, 
									  cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	}
}