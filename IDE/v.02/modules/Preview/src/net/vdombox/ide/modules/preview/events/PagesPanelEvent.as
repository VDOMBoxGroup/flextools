package net.vdombox.ide.modules.preview.events
{
	import flash.events.Event;

	public class PagesPanelEvent extends Event
	{
		public static var PAGE_CHANGED : String = "pageChanged";

		public function PagesPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new PagesPanelEvent( type, bubbles, cancelable );
		}
	}
}