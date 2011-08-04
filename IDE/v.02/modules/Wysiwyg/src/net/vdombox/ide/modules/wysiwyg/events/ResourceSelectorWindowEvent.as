package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;
	
	public class ResourceSelectorWindowEvent extends Event
	{
		public static var CLOSE 			: String = "closeWindow";
		public static var APPLY 			: String = "apply";
		public static var LOAD_RESOURCE 	: String = "loadResource";
		public static var GET_RESOURCE		: String = "getResource";
		public static var GET_ICON			: String = "getIcon";
		public static var GET_RESOURCES		: String = "getResources";
		public static var PREVIEW_RESOURCE	: String = "previewResource";
		
		public function ResourceSelectorWindowEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ResourceSelectorWindowEvent( type, bubbles, cancelable );
		}
	}
}