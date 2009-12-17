package net.vdombox.ide.modules.applicationsManagment.events
{
	import flash.events.Event;
	
	public class EditApplicationViewEvent extends Event
	{
		public static var APPLICATION_NAME_CHANGED : String = "applicationNameChanged";
		
		public function EditApplicationViewEvent( type : String, bubbles : Boolean = false, 
													cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	}
}