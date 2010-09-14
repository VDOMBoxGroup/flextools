package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class RendererEvent extends Event
	{
		public static var CREATED : String = "rendererCreated";
		public static var REMOVED : String = "rendererRemoved";
		public static var GET_RESOURCE : String = "rendererGetResource";
		public static var CLICKED : String = "rendererClicked";
		public static var MOVE : String = "rendererMove";

		public function RendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new RendererEvent( type, bubbles, cancelable );
		}
	}
}