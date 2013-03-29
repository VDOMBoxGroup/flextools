package net.vdombox.object_editor.event
{
	import flash.events.Event;

	public class DocumentationSettingsEvent extends Event
	{
		
		public static var SAVE_DOC_SETTINGS : String = "saveDocSettings";
        public static var CANCEL_DOC_SETTINGS : String = "cancelDocSettings";

		public function DocumentationSettingsEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new DocumentationSettingsEvent( type, bubbles, cancelable );
		}
	}
}