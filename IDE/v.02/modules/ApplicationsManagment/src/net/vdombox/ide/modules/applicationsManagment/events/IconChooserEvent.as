package net.vdombox.ide.modules.applicationsManagment.events
{
	import flash.events.Event;
	
	public class IconChooserEvent extends Event
	{
		public static var LOAD_ICON : String = "loadIcon";
		
		public function IconChooserEvent( type : String, bubbles : Boolean = false, 
													cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	}
}