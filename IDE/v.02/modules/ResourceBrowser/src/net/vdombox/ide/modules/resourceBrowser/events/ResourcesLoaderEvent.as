package net.vdombox.ide.modules.resourceBrowser.events
{
	import flash.events.Event;

	public class ResourcesLoaderEvent extends Event
	{
		public static var START_UPLOAD : String = "startUpload";

		public function ResourcesLoaderEvent( type : String, bubbles : Boolean = false,
			cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new ResourcesLoaderEvent( type, bubbles, cancelable );
		}
	}
}