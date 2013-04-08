package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;

	public class TreeElementEvent extends Event
	{
		public static var CREATED : String = "elementCreated";

		public static var REMOVED : String = "elementRemoved";

		public static var SELECTION : String = "elementSelection";

		public static var STATE_CHANGED : String = "stateChanged";

		public static var DELETE : String = "delete";

		public static var CREATE_LINKAGE : String = "createLinkage";

		public static var DELETE_LINKAGE : String = "deleteLinkage";

		public static var MOVED : String = "moved";

		public static var SAVE_PAGE_NAME : String = "savePageName";

		public static var SAVE_PAGE_ATTRIBUTES : String = "savePageAttributes";

		public static var MULTI_SELECTED : String = "multiSelected";

		public static var MULTI_SELECT_MOVED : String = "multiSelectedMoved";

		public static var CLICK : String = "elementClick";

		public static var MOVE : String = "elementMove";


		public var object : Object;


		public function TreeElementEvent( type : String, _object : Object = null, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
			object = _object;
		}

		override public function clone() : Event
		{
			return new TreeElementEvent( type, bubbles, cancelable );
		}
	}
}
