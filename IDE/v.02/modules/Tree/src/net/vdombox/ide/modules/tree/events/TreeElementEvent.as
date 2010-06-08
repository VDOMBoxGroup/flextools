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
		
		
		public function TreeElementEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new TreeElementEvent( type, bubbles, cancelable );
		}
	}
}