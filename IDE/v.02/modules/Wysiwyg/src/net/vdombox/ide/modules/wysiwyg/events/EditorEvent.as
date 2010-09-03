package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;
	
	public class EditorEvent extends Event
	{
		public static var CREATED : String = "created";
		public static var XML_EDITOR_OPENED : String = "xmlEditorOpened";
		public static var WYSIWYG_OPENED : String = "wysiwygOpened";
		
		public function EditorEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new AttributeEvent( type, bubbles, cancelable );
		}
	}
}