package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class ObjectsTreePanelEvent extends Event
	{
		public static var CHANGE : String = "otpe_change";
		public static var OPEN : String = "otpe_open";

		public function ObjectsTreePanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, pageID : String = null,
											   objectID : String = null )
		{
			super( type, bubbles, cancelable );
			this.pageID = pageID;
			this.objectID = objectID;
		}

		public var pageID : String;
		public var objectID : String;

		override public function clone() : Event
		{
			return new ObjectsTreePanelEvent( type, bubbles, cancelable, pageID, objectID );
		}
	}
}