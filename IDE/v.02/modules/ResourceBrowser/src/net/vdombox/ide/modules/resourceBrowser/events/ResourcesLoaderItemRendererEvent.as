package net.vdombox.ide.modules.resourceBrowser.events
{
	import flash.events.Event;

	public class ResourcesLoaderItemRendererEvent extends Event
	{
		public static var REMOVE : String = "remove";

		public function ResourcesLoaderItemRendererEvent( type : String, bubbles : Boolean = false,
			cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ResourcesLoaderItemRendererEvent( type, bubbles, cancelable );
		}
	}
}