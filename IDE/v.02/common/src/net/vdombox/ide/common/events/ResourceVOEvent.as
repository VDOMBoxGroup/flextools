package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class ResourceVOEvent extends Event
	{
		public static var CLOSE 							: String = "closeWindow";
		public static var APPLY 							: String = "apply";
		public static var LOAD_RESOURCE 					: String = "loadResource";
		public static var GET_RESOURCE_REQUEST						: String = "getResourceRequest";
		public static var GET_ICON							: String = "getIcon";
		public static var GET_RESOURCES						: String = "getResources";
		public static var PREVIEW_RESOURCE					: String = "previewResource";
		public static var RESOURCE_FILE_LOADING_STARTED		: String = "resourceFileLoadingStarted";
		public static var RESOURCE_FILE_LOADING_COMPLETED	: String = "resourceFileLoadingCompleted";
		
		public static var CREATION_COMPLETE					: String = "creationComplete";
		public static var LIST_ITEM_CREATION_COMPLETE		: String = "listItemCreationComplete";
		
		public function ResourceVOEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ResourceVOEvent( type, bubbles, cancelable );
		}
	}
}