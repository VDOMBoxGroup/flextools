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
		
		public function AttributeEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new AttributeEvent( type, bubbles, cancelable );
		}
	}
}