package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class ToolbarEvent extends Event
	{
		public static var IMAGE_CHANGED : String = "imageChanged";

		public function ToolbarEvent( type : String, body : Object = null, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
			this.body = body;
		}

		public var body : Object;
		
		override public function clone() : Event
		{
			return new ToolbarEvent( type, body, bubbles, cancelable );
		}
	}
}