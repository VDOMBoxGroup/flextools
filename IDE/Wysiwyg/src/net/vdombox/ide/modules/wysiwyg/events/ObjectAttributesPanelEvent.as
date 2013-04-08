package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class ObjectAttributesPanelEvent extends Event
	{
		public static var SAVE_REQUEST : String = "saveRequest";

		public static var CURRENT_ATTRIBUTE_CHANGED : String = "currentAttributeChanged";

		public static var SELECTED_ATTRIBUTE_CHANGED : String = "selectedAttributeChanged";

		public function ObjectAttributesPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ObjectAttributesPanelEvent( type, bubbles, cancelable );
		}
	}
}
