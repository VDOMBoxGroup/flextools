package net.vdombox.ide.modules.resourceBrowser.events
{
	import flash.events.Event;

	public class ResourcesListItemRendererEvent extends Event
	{
		public static var CREATED : String = "created";

		public function ResourcesListItemRendererEvent( type : String, bubbles : Boolean = false,
			cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ResourcesListItemRendererEvent( type, bubbles, cancelable );
		}
	}
}