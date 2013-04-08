package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class AttributeEvent extends Event
	{
		//todo rename
		public static var CHOSE_RESOURCES_IN_MULTILINE : String = "choseResourceInMultiline";

		public static var EDIT_MULTILINE : String = "editMultiline";

		public static var SELECT_RESOURCE : String = "selectResource";

		public static var OPEN_EXTERNAL : String = "openExternal";

		public static var ERROR1 : String = "errorAttribute1";

		public static var ERROR2 : String = "errorAttribute2";

		public var value : String;

		public function AttributeEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			var newEvent : AttributeEvent = new AttributeEvent( type, bubbles, cancelable );
			newEvent.value = value;
			return newEvent;
		}
	}
}
