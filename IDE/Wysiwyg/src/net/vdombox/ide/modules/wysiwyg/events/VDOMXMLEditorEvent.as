package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class VDOMXMLEditorEvent extends Event
	{
		public static var SAVE : String = "save";

		public function VDOMXMLEditorEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new VDOMXMLEditorEvent( type, bubbles, cancelable );
		}
	}
}
