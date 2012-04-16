package net.vdombox.ide.modules.events.events
{
	import flash.events.Event;
	
	public class ElementEvent extends Event
	{
		public static var STATE_CHANGED : String = "stateChanged";
		public static var CREATE_LINKAGE : String = "createLinkage";
		public static var DELETE_LINKAGE : String = "deleteLinkage";
		public static var DELETE : String = "delete";
		public static var MOUSE_DOWN : String = "elementMouseDown";
		public static var MOVE : String = "elementMove";
		public static var MOVED : String = "moved";
		public static var PARAMETER_EDIT : String = "parameterEdit";
		public static var CLICK : String = "elementClick";
		public static var MULTI_SELECTED : String = "multiSelected";
		public static var MULTI_SELECT_MOVED : String = "multiSelectMoved";
		
		public var object : Object;
		
		public function ElementEvent( type : String, _object : Object = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
			object = _object;
		}
		
		override public function clone() : Event
		{
			return new ElementEvent( type, bubbles, cancelable );
		}
	}
}