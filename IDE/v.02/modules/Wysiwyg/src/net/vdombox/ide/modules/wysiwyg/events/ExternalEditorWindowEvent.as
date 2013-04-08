package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class ExternalEditorWindowEvent extends Event
	{
		public static var CLOSE : String = "closeWindow";

		public static var APPLY : String = "apply";

		public function ExternalEditorWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ExternalEditorWindowEvent( type, bubbles, cancelable );
		}
	}
}
