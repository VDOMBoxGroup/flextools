package net.vdombox.ide.modules.applicationsManagment.events
{
	import flash.events.Event;

	public class CreateApplicationViewEvent extends Event
	{
		public static var SHOW_ICONS_GALLERY : String = "showIconsGallery";
		public static var LOAD_ICON : String = "loadIcon";
		
		public static var SAVE : String = "save";
		public static var CANCEL : String = "cancel";
		
		public function CreateApplicationViewEvent( type : String, bubbles : Boolean = false, 
												cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
	}
}