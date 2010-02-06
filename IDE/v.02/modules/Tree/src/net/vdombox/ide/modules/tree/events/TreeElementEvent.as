package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;
	
	public class TreeElementEvent extends Event
	{
		public static var ELEMENT_SELECTION : String = "elementSelection";
		
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