package net.vdombox.ide.modules.events.events
{
	import flash.events.Event;
	
	public class ElementEvent extends Event
	{
		public static var STATE_CHANGED : String = "stateChanged";
		public static var CREATE_LINKAGE : String = "createLinkage";
		public static var DELETE_LINKAGE : String = "deleteLinkage";
		public static var DELETE : String = "delete";
		public static var MOVED : String = "moved";
		public static var SHOW_ELEMENT	 : String = "showElement";
		
		public function ElementEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ElementEvent( type, bubbles, cancelable );
		}
	}
}